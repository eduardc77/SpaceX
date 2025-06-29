//
//  LaunchPatch.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct LaunchPatch: Codable, Sendable, Equatable {
    public let small: String?
    public let large: String?
    
    public init(
        small: String? = nil,
        large: String? = nil
    ) {
        self.small = small
        self.large = large
    }
}
