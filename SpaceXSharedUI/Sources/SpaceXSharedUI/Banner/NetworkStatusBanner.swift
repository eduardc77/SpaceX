//
//  NetworkStatusBanner.swift
//  SpaceXSharedUI
//
//  Created by User on 6/24/25.
//

import SwiftUI
import SpaceXUtilities

public struct NetworkStatusBanner: View {
    @Environment(NetworkMonitor.self) private var networkMonitor
    @State private var showBanner = false
    @State private var bannerOffset: CGFloat = 100
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if !networkMonitor.isConnected {
                HStack(spacing: 12) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(.networkNoConnection)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(.networkCachedData)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.gradient)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: -5)
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .offset(y: bannerOffset)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        bannerOffset = 0
                    }
                }
                .onDisappear {
                    bannerOffset = 100
                }
            }
        }
        .animation(.default, value: networkMonitor.isConnected)
        
    }
}

public extension View {
    func withNetworkStatusBanner() -> some View {
        ZStack(alignment: .bottom) {
            self
            NetworkStatusBanner()
        }
    }
}
