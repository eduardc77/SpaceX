//
//  MainTabView.swift
//  SpaceX
//
//  Created by User on 6/27/25.
//

import SwiftUI
import SpaceXDomain

struct MainTabView: View {
    @Environment(SpaceXRepositories.self) private var repositories
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem {
                        Image(systemName: tab.icon)
                        Text(tab.title)
                    }
                    .tag(tab)
            }
        }
    }
    
    @ViewBuilder
    private func tabContent(for tab: AppTab) -> some View {
        switch tab {
        case .home:
            SpaceXHomeScreen(repositories: repositories)
        case .settings:
            SettingsView()
        }
    }
}

#if DEBUG
import SpaceXMocks
import SpaceXUtilities

#Preview {
    MainTabView()
        .environment(HomeCoordinator())
        .environment(NetworkMonitor())
        .environment(createMockRepositories())
} 
#endif
