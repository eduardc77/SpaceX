//
//  LaunchDetailWebViewRepresentable.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI

struct LaunchDetailWebViewRepresentable: UIViewControllerRepresentable {
    let url: URL
    let coordinator: LaunchWebViewCoordinator
    
    func makeUIViewController(context: Context) -> LaunchDetailWebViewController {
        let controller = LaunchDetailWebViewController(url: url)
        controller.coordinator = coordinator
        coordinator.webViewController = controller
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LaunchDetailWebViewController, context: Context) {
        // No updates needed
    }
}
