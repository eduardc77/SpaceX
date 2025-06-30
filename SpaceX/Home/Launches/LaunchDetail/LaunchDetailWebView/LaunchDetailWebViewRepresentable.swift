//
//  LaunchDetailWebViewRepresentable.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI

struct LaunchDetailWebViewRepresentable: UIViewControllerRepresentable {
    let url: URL
    let store: WebViewStore
    
    func makeUIViewController(context: Context) -> LaunchDetailWebViewController {
        let controller = LaunchDetailWebViewController(url: url)
        controller.store = store
        store.webViewController = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LaunchDetailWebViewController, context: Context) {
        // Update URL if needed
        if uiViewController.url != url {
            uiViewController.url = url
            uiViewController.loadContent()
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: LaunchDetailWebViewController, coordinator: ()) {
        // Proper cleanup when the view is removed
        uiViewController.cleanup()
    }
}
