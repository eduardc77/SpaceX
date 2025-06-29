//
//  LaunchLinksDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct LaunchLinksDTO: Codable, Sendable {
    let patch: LaunchPatchDTO?
    let webcast: String?
    let wikipedia: String?
    let article: String?
    
    func toDomain() -> LaunchLinks {
        LaunchLinks(
            patch: patch?.toDomain(),
            webcast: webcast,
            wikipedia: wikipedia,
            article: article
        )
    }
}
