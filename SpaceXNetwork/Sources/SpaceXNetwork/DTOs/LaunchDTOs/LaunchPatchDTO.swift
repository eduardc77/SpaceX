//
//  LaunchPatchDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct LaunchPatchDTO: Codable, Sendable {
    let small: String?
    let large: String?
    
    func toDomain() -> LaunchPatch {
        LaunchPatch(small: small, large: large)
    }
}
