//
//  LaunchDetailWebView.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI

struct LaunchDetailWebView: View {
    let url: URL
    let title: LocalizedStringKey
    
    @State private var coordinator = LaunchWebViewCoordinator()
    
    var body: some View {
        LaunchDetailWebViewRepresentable(url: url, coordinator: coordinator)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(edges: .bottom)
            .toolbar {
                ToolbarItemGroup(placement: .confirmationAction) {
                    Button {
                        coordinator.goBack()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .disabled(!coordinator.canGoBack)
                    
                    Button {
                        coordinator.goForward()
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                    .disabled(!coordinator.canGoForward)
                    
                    Button {
                        coordinator.refresh()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
    }
}

#Preview {
    if let url = URL(string: "https://www.spacex.com") {
        LaunchDetailWebView(
            url: url,
            title: "SpaceX Mission"
        )
    }
}
