//
//  SettingsView.swift
//  SpaceX
//
//  Created by User on 6/27/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    appearanceRow
                } header: {
                    Text(.settingsAppearanceHeader)
                } footer: {
                    Text(.settingsAppearanceFooter)
                }
                
                Section {
                    HStack {
                        Text(.settingsVersion)
                        Spacer()
                        Text(viewModel.fullVersionString)
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text(.settingsAboutHeader)
                }
            }
            .listSectionSpacing(16)
            .contentMargins(.top, 16, for: .scrollContent)
            .navigationTitle(.settingsTitle)
        }
    }
    
    // MARK: - Subviews
    
    private var appearanceRow: some View {
        HStack {
            Image(systemName: "circle.righthalf.fill")
                .foregroundColor(.purple)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(.settingsDarkMode)
                    .foregroundStyle(.primary)
                Text(.settingsDarkModeDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
} 
