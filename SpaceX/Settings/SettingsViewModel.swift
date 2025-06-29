//
//  SettingsViewModel.swift
//  SpaceX
//
//  Created by User on 6/27/25.
//

import Foundation

@MainActor
@Observable
class SettingsViewModel {
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var fullVersionString: String {
        "\(appVersion) (\(buildNumber))"
    }
} 
