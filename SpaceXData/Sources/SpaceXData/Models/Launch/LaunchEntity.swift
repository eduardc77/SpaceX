//
//  LaunchEntity.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import SpaceXDomain

@Model
final class LaunchEntity {
    @Attribute(.unique) var id: String
    var name: String
    var details: String?
    var upcoming: Bool
    var success: Bool?
    var dateUtc: String
    var dateUnix: Int
    var rocket: String
    var flightNumber: Int
    
    @Relationship(deleteRule: .cascade)
    var links: LaunchLinksEntity?
    
    @Relationship(deleteRule: .cascade)
    var cores: [LaunchCoreEntity] = []
    
    init(
        id: String,
        name: String,
        details: String? = nil,
        upcoming: Bool,
        success: Bool? = nil,
        dateUtc: String,
        dateUnix: Int,
        rocket: String,
        flightNumber: Int,
        links: LaunchLinksEntity? = nil,
        cores: [LaunchCoreEntity] = []
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.upcoming = upcoming
        self.success = success
        self.dateUtc = dateUtc
        self.dateUnix = dateUnix
        self.rocket = rocket
        self.flightNumber = flightNumber
        self.links = links
        self.cores = cores
    }
}

// MARK: - Domain Mapping

extension LaunchEntity {
    func toDomain() -> Launch {
        let links = self.links?.toDomain() ?? LaunchLinks()
        let cores = self.cores.map { $0.toDomain() }
        
        return Launch(
            id: id,
            name: name,
            details: details,
            upcoming: upcoming,
            success: success,
            dateUtc: dateUtc,
            dateUnix: dateUnix,
            links: links,
            rocket: rocket,
            flightNumber: flightNumber,
            cores: cores
        )
    }
    
    /// Create SwiftData entity from Domain model with proper relationship handling
    static func fromDomain(_ launch: Launch) -> LaunchEntity {
        let entity = LaunchEntity(
            id: launch.id,
            name: launch.name,
            details: launch.details,
            upcoming: launch.upcoming,
            success: launch.success,
            dateUtc: launch.dateUtc,
            dateUnix: launch.dateUnix,
            rocket: launch.rocket,
            flightNumber: launch.flightNumber
        )
        
        // Create and assign nested entities after main entity creation
        entity.links = LaunchLinksEntity.fromDomain(launch.links)
        entity.cores = launch.cores.map { LaunchCoreEntity.fromDomain($0) }
        
        return entity
    }
    
    /// Update existing entity with data from Domain model
    func updateFromDomain(_ launch: Launch) {
        // Update all properties (except id which is unique)
        self.name = launch.name
        self.details = launch.details
        self.upcoming = launch.upcoming
        self.success = launch.success
        self.dateUtc = launch.dateUtc
        self.dateUnix = launch.dateUnix
        self.rocket = launch.rocket
        self.flightNumber = launch.flightNumber
        
        // Update relationships instead of recreating them
        if let existingLinks = self.links {
            existingLinks.updateFromDomain(launch.links)
        } else {
            self.links = LaunchLinksEntity.fromDomain(launch.links)
        }

        // Update cores efficiently instead of recreating all
        updateCoresFromDomain(launch.cores)
    }

    /// Efficiently update cores by reusing existing entities when possible
    private func updateCoresFromDomain(_ domainCores: [LaunchCore]) {
        // If same number of cores, update existing ones
        if self.cores.count == domainCores.count {
            for (index, domainCore) in domainCores.enumerated() where index < self.cores.count {
                self.cores[index].updateFromDomain(domainCore)
            }
        } else {
            // Different number of cores, need to recreate
            self.cores.removeAll()
            self.cores = domainCores.map { LaunchCoreEntity.fromDomain($0) }
        }
    }
}
