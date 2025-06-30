//
//  LaunchCoreEntity.swift
//  SpaceXData
//
//  Created by User on 6/26/25.
//

import SwiftData
import SpaceXDomain

@Model
final class LaunchCoreEntity {
    var core: String?
    var flight: Int?
    var reused: Bool?
    var landingAttempt: Bool?
    var landingSuccess: Bool?
    
    @Relationship(inverse: \LaunchEntity.cores)
    var launch: LaunchEntity?
    
    init(
        core: String? = nil,
        flight: Int? = nil,
        reused: Bool? = nil,
        landingAttempt: Bool? = nil,
        landingSuccess: Bool? = nil
    ) {
        self.core = core
        self.flight = flight
        self.reused = reused
        self.landingAttempt = landingAttempt
        self.landingSuccess = landingSuccess
    }
}

extension LaunchCoreEntity {
    func toDomain() -> LaunchCore {
        return LaunchCore(
            core: core,
            flight: flight,
            reused: reused,
            landingAttempt: landingAttempt,
            landingSuccess: landingSuccess
        )
    }
    
    static func fromDomain(_ core: LaunchCore) -> LaunchCoreEntity {
        return LaunchCoreEntity(
            core: core.core,
            flight: core.flight,
            reused: core.reused,
            landingAttempt: core.landingAttempt,
            landingSuccess: core.landingSuccess
        )
    }

    func updateFromDomain(_ core: LaunchCore) {
        self.core = core.core
        self.flight = core.flight
        self.reused = core.reused
        self.landingAttempt = core.landingAttempt
        self.landingSuccess = core.landingSuccess
    }
}
