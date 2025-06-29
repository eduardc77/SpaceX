//
//  LaunchPatchEntity.swift
//  SpaceXData
//
//  Created by User on 6/26/25.
//

import SwiftData
import SpaceXDomain

@Model
final class LaunchPatchEntity {
    var small: String?
    var large: String?
    
    @Relationship(inverse: \LaunchLinksEntity.patch)
    var links: LaunchLinksEntity?
    
    init(small: String? = nil, large: String? = nil) {
        self.small = small
        self.large = large
    }
}

extension LaunchPatchEntity {
    func toDomain() -> LaunchPatch {
        return LaunchPatch(small: small, large: large)
    }
    
    static func fromDomain(_ patch: LaunchPatch) -> LaunchPatchEntity {
        return LaunchPatchEntity(small: patch.small, large: patch.large)
    }
    
    func updateFromDomain(_ patch: LaunchPatch) {
        self.small = patch.small
        self.large = patch.large
    }
}
