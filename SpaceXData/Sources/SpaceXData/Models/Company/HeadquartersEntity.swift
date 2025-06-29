//
//  HeadquartersEntity.swift
//  SpaceXData
//
//  Created by User on 6/26/25.
//

import SwiftData
import Foundation
import SpaceXDomain

@Model
final class HeadquartersEntity {
    var address: String
    var city: String
    var state: String
    
    var company: CompanyEntity?
    
    init(address: String, city: String, state: String) {
        self.address = address
        self.city = city
        self.state = state
    }
}

extension HeadquartersEntity {
    func toDomain() -> Headquarters {
        return Headquarters(address: address, city: city, state: state)
    }
    
    static func fromDomain(_ headquarters: Headquarters) -> HeadquartersEntity {
        return HeadquartersEntity(
            address: headquarters.address,
            city: headquarters.city,
            state: headquarters.state
        )
    }
}
