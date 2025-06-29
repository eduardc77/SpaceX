//
//  MissionPatchImage.swift
//  SpaceXSharedUI
//
//  Created by User on 6/24/25.
//

import SwiftUI
import Kingfisher
import SpaceXDomain

public struct MissionPatchImage: View {
    let launch: Launch
    let size: CGFloat
    let cornerRadius: CGFloat
    let showPlaceholder: Bool
    
    public init(
        launch: Launch,
        size: CGFloat = 50,
        cornerRadius: CGFloat = 4,
        showPlaceholder: Bool = true
    ) {
        self.launch = launch
        self.size = size
        self.cornerRadius = cornerRadius
        self.showPlaceholder = showPlaceholder
    }
    
    public var body: some View {
        let imageURL: URL? = {
            guard let urlString = launch.links.patch?.small,
                  !urlString.isEmpty else { return nil }
            return URL(string: urlString)
        }()
        
        AsyncImageView(
            url: imageURL,
            size: CGSize(width: size, height: size),
            cornerRadius: cornerRadius,
            showPlaceholder: showPlaceholder,
            placeholderIcon: "airplane.departure",
            contentMode: .fit,
            context: launch.name
        )
    }
}

public extension MissionPatchImage {
    
    static func small(launch: Launch) -> MissionPatchImage {
        MissionPatchImage(launch: launch, size: 50, cornerRadius: 8)
    }
    
    static func medium(launch: Launch) -> MissionPatchImage {
        MissionPatchImage(launch: launch, size: 100, cornerRadius: 12)
    }
    
    static func large(launch: Launch) -> MissionPatchImage {
        MissionPatchImage(launch: launch, size: 150, cornerRadius: 16)
    }
    
    static func overlay(launch: Launch, size: CGFloat) -> MissionPatchImage {
        MissionPatchImage(launch: launch, size: size, cornerRadius: 8, showPlaceholder: false)
    }
}

#if DEBUG
import SpaceXMocks

#Preview {
    VStack(spacing: 20) {
        MissionPatchImage.small(launch: MockLaunchData.successLaunch)
        MissionPatchImage.medium(launch: MockLaunchData.failureLaunch)
        MissionPatchImage.large(launch: MockLaunchData.upcomingLaunch)
        
        // Custom
        MissionPatchImage(launch: MockLaunchData.starshipSuccess, size: 80, cornerRadius: 20)
    }
    .padding()
}
#endif
