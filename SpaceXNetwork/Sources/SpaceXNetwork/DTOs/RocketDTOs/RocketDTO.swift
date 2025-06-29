//
//  RocketDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct RocketDTO: Codable, Sendable {
    let id: String
    let name: String
    let description: String
    let active: Bool
    let costPerLaunch: Int?
    let successRatePct: Int
    let flickrImages: [String]
    let wikipedia: String
    
    func toDomain() -> Rocket {
        Rocket(
            id: id,
            name: name,
            description: description,
            active: active,
            costPerLaunch: costPerLaunch,
            successRatePct: successRatePct,
            flickrImages: flickrImages,
            wikipedia: wikipedia
        )
    }
}
