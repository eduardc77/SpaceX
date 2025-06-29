//
//  ContentView.swift
//  SpaceX
//
//  Created by User on 6/29/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        MainTabView()
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#if DEBUG
import SpaceXMocks
import SpaceXUtilities

#Preview {
    ContentView()
        .environment(HomeCoordinator())
        .environment(NetworkMonitor())
        .environment(createMockRepositories())
}
#endif
