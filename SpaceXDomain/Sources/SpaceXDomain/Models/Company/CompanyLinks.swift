//
//  CompanyLinks.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct CompanyLinks: Codable, Sendable {
    public let website: String
    public let twitter: String
    
    public init(
        website: String,
        twitter: String
    ) {
        self.website = website
        self.twitter = twitter
    }
}
