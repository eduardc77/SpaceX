//
//  Rocket.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct Rocket: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let active: Bool
    public let costPerLaunch: Int?
    public let successRatePct: Int
    public let flickrImages: [String]
    public let wikipedia: String
    
    public init(
        id: String,
        name: String,
        description: String,
        active: Bool,
        costPerLaunch: Int? = nil,
        successRatePct: Int,
        flickrImages: [String],
        wikipedia: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.active = active
        self.costPerLaunch = costPerLaunch
        self.successRatePct = successRatePct
        self.flickrImages = flickrImages
        self.wikipedia = wikipedia 
    }
}
