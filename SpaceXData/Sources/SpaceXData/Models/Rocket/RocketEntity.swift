//
//  RocketEntity.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import Foundation
import SpaceXDomain
import SpaceXUtilities

@Model
final class RocketEntity {
    @Attribute(.unique) var id: String
    var name: String
    var rocketDescription: String
    var active: Bool
    var costPerLaunch: Int?
    var successRatePct: Int
    var wikipedia: String
    var flickrImagesData: Data?
    
    init(
        id: String,
        name: String,
        rocketDescription: String,
        active: Bool,
        costPerLaunch: Int? = nil,
        successRatePct: Int,
        wikipedia: String,
        flickrImagesData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.rocketDescription = rocketDescription
        self.active = active
        self.costPerLaunch = costPerLaunch
        self.successRatePct = successRatePct
        self.wikipedia = wikipedia
        self.flickrImagesData = flickrImagesData
    }
}

// MARK: - Domain Mapping

extension RocketEntity {
    /// Convert SwiftData entity to Domain model
    func toDomain() -> Rocket {
        let flickrImages = decodeFlickrImages()
        
        return Rocket(
            id: id,
            name: name,
            description: rocketDescription,
            active: active,
            costPerLaunch: costPerLaunch,
            successRatePct: successRatePct,
            flickrImages: flickrImages,
            wikipedia: wikipedia
        )
    }
    
    /// Create SwiftData entity from Domain model
    static func fromDomain(_ rocket: Rocket) -> RocketEntity {
        let entity = RocketEntity(
            id: rocket.id,
            name: rocket.name,
            rocketDescription: rocket.description,
            active: rocket.active,
            costPerLaunch: rocket.costPerLaunch,
            successRatePct: rocket.successRatePct,
            wikipedia: rocket.wikipedia
        )
        
        entity.encodeFlickrImages(rocket.flickrImages)
        
        return entity
    }
    
    // MARK: - Private Encoding/Decoding Helpers
    
    private func decodeFlickrImages() -> [String] {
        guard let flickrImagesData = flickrImagesData else { return [] }
        do {
            return try JSONDecoder().decode([String].self, from: flickrImagesData)
        } catch {
            SpaceXLogger.error("Failed to decode flickr images: \(error)")
            return []
        }
    }
    
    private func encodeFlickrImages(_ images: [String]) {
        do {
            self.flickrImagesData = try JSONEncoder().encode(images)
        } catch {
            SpaceXLogger.error("Failed to encode flickr images: \(error)")
            self.flickrImagesData = nil
        }
    }
}
