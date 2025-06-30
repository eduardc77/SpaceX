//
//  WebViewStore.swift
//  SpaceX
//
//  Created by User on 6/30/25.
//

import Observation

@Observable final class WebViewStore {
    var canGoBack = false
    var canGoForward = false

    @ObservationIgnored weak var webViewController: LaunchDetailWebViewController?

    func goBack() {
        webViewController?.goBack()
    }

    func goForward() {
        webViewController?.goForward()
    }

    func refresh() {
        webViewController?.refresh()
    }

    func updateNavigationState(canGoBack: Bool, canGoForward: Bool) {
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
    }
}
