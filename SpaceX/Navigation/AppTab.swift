//
//  AppTab.swift
//  SpaceX
//
//  Created by User on 6/27/25.
//

enum AppTab: String, CaseIterable, Hashable {
    case home
    case settings
    
    var title: String {
        switch self {
        case .home:
            return String(localized: "tab.home")
        case .settings:
            return String(localized: "tab.settings")
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "house"
        case .settings:
            return "gear"
        }
    }
} 
