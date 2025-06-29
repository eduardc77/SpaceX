//
//  LaunchCoreDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct LaunchCoreDTO: Codable, Sendable {
    let core: String?
    let flight: Int?
    let reused: Bool?
    let landingAttempt: Bool?
    let landingSuccess: Bool?
    
    func toDomain() -> LaunchCore {
        LaunchCore(
            core: core,
            flight: flight,
            reused: reused,
            landingAttempt: landingAttempt,
            landingSuccess: landingSuccess
        )
    }
}
