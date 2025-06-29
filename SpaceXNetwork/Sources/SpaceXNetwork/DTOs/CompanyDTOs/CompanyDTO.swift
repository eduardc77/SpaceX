//
//  CompanyDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct CompanyDTO: Codable, Sendable {
    let name: String
    let founder: String
    let founded: Int
    let employees: Int
    let ceo: String
    let valuation: Int64
    let headquarters: HeadquartersDTO
    let links: CompanyLinksDTO
    let summary: String
    
    func toDomain() -> Company {
        Company(
            name: name,
            founder: founder,
            founded: founded,
            employees: employees,
            ceo: ceo,
            valuation: valuation,
            headquarters: headquarters.toDomain(),
            links: links.toDomain(),
            summary: summary
        )
    }
}
