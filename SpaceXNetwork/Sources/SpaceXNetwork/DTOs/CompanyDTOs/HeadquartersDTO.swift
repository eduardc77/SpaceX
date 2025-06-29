//
//  HeadquartersDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct HeadquartersDTO: Codable, Sendable {
    let address: String
    let city: String
    let state: String
    
    func toDomain() -> Headquarters {
        Headquarters(
            address: address,
            city: city,
            state: state
        )
    }
}
