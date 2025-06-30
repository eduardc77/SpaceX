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
    
    @State private var webViewStore = WebViewStore()
    
    var body: some View {
        LaunchDetailWebViewRepresentable(
            url: url,
            store: webViewStore
        )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .confirmationAction) {
                Button {
                    webViewStore.goBack()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .disabled(!webViewStore.canGoBack)
                
                Button {
                    webViewStore.goForward()
                } label: {
                    Image(systemName: "chevron.forward")
                }
                .disabled(!webViewStore.canGoForward)
                
                Button {
                    webViewStore.refresh()
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
