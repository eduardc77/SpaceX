//
//  LaunchLinks.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct LaunchLinks: Codable, Sendable, Equatable {
    public let patch: LaunchPatch?
    public let webcast: String?
    public let wikipedia: String?
    public let article: String?

    public init(
        patch: LaunchPatch? = nil,
        webcast: String? = nil,
        wikipedia: String? = nil,
        article: String? = nil
    ) {
        self.patch = patch
        self.webcast = webcast
        self.wikipedia = wikipedia
        self.article = article
    }
}
