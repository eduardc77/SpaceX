//
//  LaunchDetailSheetView.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain
import SpaceXSharedUI

struct LaunchDetailSheetView: View {
    let launch: Launch
    @Environment(HomeCoordinator.self) private var coordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                headerSection
                statusSection
                detailsSection
                externalLinksSection
            }
            .contentMargins(.top, 10, for: .scrollContent)
            .listSectionSpacing(6)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(.actionDone)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        Section {
            VStack {
                MissionPatchImage.medium(launch: launch)
                
                Text(launch.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(LocalizedStringKey.launchFlightNumber(launch.flightNumber))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Text(launch.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 20, trailing: 0))
        .listRowBackground(Color.clear)
    }
    
    private var statusSection: some View {
        Section {
            VStack(alignment: .trailing, spacing: 12) {
                LabeledContent(.launchMissionStatus) {
                    HStack {
                        Image(systemName: launch.statusIcon)
                            .foregroundStyle(launch.statusColor)
                        
                        Text(launch.statusText)
                            .foregroundStyle(.primary)
                            .fontWeight(.medium)
                    }
                }
                
                Text(launch.daysFromNowText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        if let details = launch.details, !details.isEmpty {
            Section {
                Text(details)
                    .font(.body)
            } header: {
                Text(.launchMissionDetails)
            }
        }
    }
    
    // Link Buttons
    
    private var externalLinksSection: some View {
        Section {
            wikipediaButton
            articleButton
            webcastButton
            spaceXWebsiteButton
        } header: {
            Text(.launchLearnMore)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private var wikipediaButton: some View {
        if launch.links.wikipedia != nil {
            Button {
                dismiss()
                coordinator.showWikipedia(for: launch)
            } label: {
                HStack {
                    Image(systemName: "safari")
                    Text(.launchViewWikipedia)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundStyle(.blue)
                .background(Color.blue.opacity(0.2))
            }
            .buttonStyle(.plain)
            .listRowInsets(.init())
        }
    }
    
    @ViewBuilder
    private var articleButton: some View {
        if launch.links.article != nil {
            Button {
                dismiss()
                coordinator.showArticle(for: launch)
            } label: {
                HStack {
                    Image(systemName: "newspaper")
                    Text(.launchReadArticle)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .foregroundStyle(.green)
                .background(Color.green.opacity(0.2))
            }
            .buttonStyle(.plain)
            .listRowInsets(.init())
        }
    }
    
    @ViewBuilder
    private var webcastButton: some View {
        if launch.links.webcast != nil {
            Button {
                dismiss()
                coordinator.showWebcast(for: launch)
            } label: {
                HStack {
                    Image(systemName: "play.rectangle")
                    Text(.launchWatchWebcast)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.red.opacity(0.2))
                .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .listRowInsets(.init())
        }
    }
    
    private var spaceXWebsiteButton: some View {
        Button {
            dismiss()
            coordinator.showSpaceXWebsite()
        } label: {
            HStack {
                Image(systemName: "globe")
                Text(.launchVisitWebsite)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .listRowInsets(.init())
    }
}

#if DEBUG
import SpaceXMocks

#Preview {
    LaunchDetailSheetView(launch: MockLaunchData.successLaunch)
        .environment(HomeCoordinator())
}
#endif
