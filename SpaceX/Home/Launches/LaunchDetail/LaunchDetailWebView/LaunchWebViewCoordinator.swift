//
//  LaunchWebViewCoordinator.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import Observation

@Observable
final class LaunchWebViewCoordinator {
    weak var webViewController: LaunchDetailWebViewController?
    
    var canGoBack = false
    var canGoForward = false
    
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
        if self.canGoBack != canGoBack {
            self.canGoBack = canGoBack
        }
        if self.canGoForward != canGoForward {
            self.canGoForward = canGoForward
        }
    }
}
