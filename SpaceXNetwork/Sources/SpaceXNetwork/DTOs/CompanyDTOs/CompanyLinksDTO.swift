//
//  CompanyLinksDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct CompanyLinksDTO: Codable, Sendable {
    let website: String
    let flickr: String
    let twitter: String
    let elonTwitter: String
    
    func toDomain() -> CompanyLinks {
        CompanyLinks(
            website: website,
            twitter: twitter
        )
    }
}
