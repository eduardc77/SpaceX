//
//  LaunchLinksEntity.swift
//  SpaceXData
//
//  Created by User on 6/26/25.
//

import SwiftData
import SpaceXDomain

@Model
final class LaunchLinksEntity {
    @Relationship(deleteRule: .cascade)
    var patch: LaunchPatchEntity?

    var webcast: String?
    var wikipedia: String?
    var article: String?

    @Relationship(inverse: \LaunchEntity.links)
    var launch: LaunchEntity?

    init(
        patch: LaunchPatchEntity? = nil,
        webcast: String? = nil,
        wikipedia: String? = nil,
        article: String? = nil
    ) {
        self.patch = patch
        self.webcast = webcast
        self.wikipedia = wikipedia
        self.article = article
    }
}

extension LaunchLinksEntity {
    func toDomain() -> LaunchLinks {
        return LaunchLinks(
            patch: patch?.toDomain(),
            webcast: webcast,
            wikipedia: wikipedia,
            article: article
        )
    }

    static func fromDomain(_ links: LaunchLinks) -> LaunchLinksEntity {
        let entity = LaunchLinksEntity(
            webcast: links.webcast,
            wikipedia: links.wikipedia,
            article: links.article
        )

        // Create nested entities
        entity.patch = links.patch.map { LaunchPatchEntity.fromDomain($0) }

        return entity
    }

    func updateFromDomain(_ links: LaunchLinks) {
        self.webcast = links.webcast
        self.wikipedia = links.wikipedia
        self.article = links.article

        // Update nested entities instead of recreating them
        if let domainPatch = links.patch {
            if let existingPatch = self.patch {
                existingPatch.updateFromDomain(domainPatch)
            } else {
                self.patch = LaunchPatchEntity.fromDomain(domainPatch)
            }
        } else {
            self.patch = nil
        }
    }
}
