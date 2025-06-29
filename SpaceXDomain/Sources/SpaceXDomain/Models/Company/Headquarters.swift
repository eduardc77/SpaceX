//
//  Headquarters.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct Headquarters: Codable, Sendable {
    public let address: String
    public let city: String
    public let state: String
    
    public init(
        address: String,
        city: String,
        state: String
    ) {
        self.address = address
        self.city = city
        self.state = state
    }
}
