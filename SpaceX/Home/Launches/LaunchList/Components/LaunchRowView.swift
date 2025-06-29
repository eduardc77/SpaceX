//
//  LaunchRowView.swift
//  SpaceX
//
//  Created by User on 6/21/25.
//

import SwiftUI
import SpaceXDomain
import SpaceXMocks
import SpaceXSharedUI

struct LaunchRowView: View {
    let launch: Launch
    let rocketName: String

    init(launch: Launch, rocketName: String = "Falcon 9") {
        self.launch = launch
        self.rocketName = rocketName
    }

    var body: some View {
        HStack {
            missionPatchImage
            launchContent
            Spacer()
            StatusBadge(
                statusColor: launch.statusColor,
                statusIcon: launch.statusIconSimple,
                statusText: launch.statusText
            )
        }
        .padding(.vertical, 8)
    }

    // MARK: - Subviews

    private var missionPatchImage: some View {
        MissionPatchImage.small(launch: launch)
    }

    private var launchContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            launchTitle
            dateInfo
            rocketInfo
            daysFromNowLabel
        }
    }

    private var launchTitle: some View {
        Text(launch.name)
            .font(.headline)
            .lineLimit(1)
    }

    private var dateInfo: some View {
        Text(launch.formattedDate)
            .font(.caption)
            .foregroundColor(.secondary)
    }

    private var rocketInfo: some View {
        Text(String(format: String(localized: "launch.rocket_label"), rocketName))
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
    }

    private var daysFromNowLabel: some View {
        Text(launch.daysFromNowText)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

#if DEBUG
import SpaceXMocks

#Preview {
    VStack {
        LaunchRowView(launch: MockLaunchData.successLaunch, rocketName: "Falcon 9")
        Divider()
        LaunchRowView(launch: MockLaunchData.failureLaunch, rocketName: "Falcon 9")
        Divider()
        LaunchRowView(launch: MockLaunchData.upcomingLaunch, rocketName: "Falcon 9")
    }
    .padding()
}
#endif
