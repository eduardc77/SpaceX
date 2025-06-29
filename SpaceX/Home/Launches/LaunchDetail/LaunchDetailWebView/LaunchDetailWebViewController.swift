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

class LaunchDetailWebViewController: UIViewController {
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var activityIndicator: UIActivityIndicatorView!
    private var cancellables = Set<AnyCancellable>()
    
    private let url: URL
    weak var coordinator: LaunchWebViewCoordinator?
    
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
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Progress View
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        view.addSubview(progressView)
        
        // Activity Indicator
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        // WebView
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view.addSubview(webView)
        
        setupConstraints()
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
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupWebViewPublishers() {
        webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressView.progress = Float(progress)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(
            webView.publisher(for: \.canGoBack),
            webView.publisher(for: \.canGoForward)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] canGoBack, canGoForward in
            self?.coordinator?.updateNavigationState(canGoBack: canGoBack, canGoForward: canGoForward)
        }
        .store(in: &cancellables)
    }
    
    private func loadContent() {
        guard url.scheme == "https" else {
            SpaceXLogger.error("Refusing to load non-HTTPS URL: \(url)")
            return
        }
        guard !activityIndicator.isAnimating else {
            SpaceXLogger.ui("Request already in progress, skipping")
            return
        }
        
        activityIndicator.startAnimating()
        let request = URLRequest(url: url)
        SpaceXLogger.network("Loading URL: \(url)")
        webView.load(request)
    }
    
    private func handleNavigationError(_ error: Error) {
        activityIndicator.stopAnimating()
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
    
    // MARK: - Actions called from SwiftUI
    
    func goBack() {
        webView.goBack()
    }
    
    func goForward() {
        webView.goForward()
    }
    
    func refresh() {
        webView.reload()
    }
    
    deinit {
        cancellables.removeAll()
    }
}

// MARK: - WKNavigationDelegate

extension LaunchDetailWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        
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
