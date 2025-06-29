//
//  CompanyLinksEntity.swift
//  SpaceXData
//
//  Created by User on 6/26/25.
//

import SwiftData
import Foundation
import SpaceXDomain

@Model
final class CompanyLinksEntity {
    var website: String
    var twitter: String
    
    var company: CompanyEntity?
    
    init(website: String, twitter: String) {
        self.website = website
        self.twitter = twitter
    }
}

extension CompanyLinksEntity {
    func toDomain() -> CompanyLinks {
        return CompanyLinks(website: website, twitter: twitter)
    }
    
    static func fromDomain(_ links: CompanyLinks) -> CompanyLinksEntity {
        return CompanyLinksEntity(
            website: links.website,
            twitter: links.twitter
        )
    }
}
