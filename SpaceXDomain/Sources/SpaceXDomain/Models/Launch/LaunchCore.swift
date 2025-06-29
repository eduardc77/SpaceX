//
//  LaunchCore.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

public struct LaunchCore: Codable, Sendable, Equatable {
    public let core: String?
    public let flight: Int?
    public let reused: Bool?
    public let landingAttempt: Bool?
    public let landingSuccess: Bool?
    
    public init(
        core: String? = nil,
        flight: Int? = nil,
        reused: Bool? = nil,
        landingAttempt: Bool? = nil,
        landingSuccess: Bool? = nil
    ) {
        self.core = core
        self.flight = flight
        self.reused = reused
        self.landingAttempt = landingAttempt
        self.landingSuccess = landingSuccess
    }
}
