//
//  LaunchDetailWebViewController.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import WebKit
import Combine
import SpaceXUtilities

final class LaunchDetailWebViewController: UIViewController {
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var cancellables = Set<AnyCancellable>()

    var url: URL
    weak var store: WebViewStore?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebViewPublishers()
        loadContent()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        webView?.stopLoading()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SpaceXLogger.ui("⚠️ WebView received memory warning - clearing cache")
        clearCache()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Progress View
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        view.addSubview(progressView)

        // WebView Configuration
        let configuration = createWebViewConfiguration()

        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .systemBackground
        view.addSubview(webView)

        setupConstraints()
    }

    private func createWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        // Memory optimization settings
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.allowsAirPlayForMediaPlayback = false

        // Use non-persistent data store to reduce memory usage
        configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()

        return configuration
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),

            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupWebViewPublishers() {
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressView.setProgress(Float(progress), animated: true)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest(
            webView.publisher(for: \.canGoBack),
            webView.publisher(for: \.canGoForward)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] canGoBack, canGoForward in
            self?.store?.updateNavigationState(canGoBack: canGoBack, canGoForward: canGoForward)
        }
        .store(in: &cancellables)
    }

    func loadContent() {
        guard url.scheme == "https" else {
            SpaceXLogger.error("Refusing to load non-HTTPS URL: \(url)")
            return
        }

        let request = URLRequest(url: url)
        SpaceXLogger.network("Loading URL: \(url)")
        webView.load(request)
    }

    private func handleNavigationError(_ error: Error) {
        progressView.isHidden = true

        let nsError = error as NSError
        SpaceXLogger.error("Navigation Error: \(nsError.localizedDescription)", category: SpaceXLogger.networking)
        SpaceXLogger.network("Error Code: \(nsError.code), Domain: \(nsError.domain)")

        // Don't show alert for cancelled requests
        guard nsError.code != NSURLErrorCancelled else {
            SpaceXLogger.network("Request was cancelled (error -999)")
            return
        }

        let alert = UIAlertController(
            title: "Loading Error",
            message: "Failed to load content: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
            self.loadContent()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    // MARK: - Actions called from Store

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func refresh() {
        webView.reload()
    }

    func clearCache() {
        SpaceXLogger.ui("🧹 Clearing WebView cache to reduce memory")

        // Clear the current webview's data store
        let websiteDataStore = webView?.configuration.websiteDataStore ?? WKWebsiteDataStore.nonPersistent()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        websiteDataStore.removeData(ofTypes: dataTypes, modifiedSince: Date.distantPast) {
            SpaceXLogger.ui("✅ WebView cache cleared")
        }

        // Also clear the content to free immediate memory
        webView?.loadHTMLString("", baseURL: nil)
    }

    // MARK: - Cleanup

    func cleanup() {
        SpaceXLogger.ui("🧹 WebViewController cleanup starting")

        // Cancel all network requests
        webView?.stopLoading()

        // Clear webview content to free memory
        webView?.loadHTMLString("", baseURL: nil)

        // Break reference cycles
        webView?.navigationDelegate = nil
        store = nil

        // Clear publishers
        cancellables.removeAll()

        // Additional cleanup for media
        webView?.configuration.userContentController.removeAllUserScripts()
        webView?.configuration.userContentController.removeAllScriptMessageHandlers()

        SpaceXLogger.ui("✅ WebViewController cleanup completed")
    }

    deinit {
        SpaceXLogger.ui("🗑️ LaunchDetailWebViewController deinit")
        // Remove subviews
        webView?.removeFromSuperview()
        webView = nil
        progressView = nil
    }
}

// MARK: - WKNavigationDelegate

extension LaunchDetailWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.3) {
                self.progressView.isHidden = true
            }
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleNavigationError(error)
    }
}
