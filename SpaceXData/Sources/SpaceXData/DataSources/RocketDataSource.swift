//
//  RocketDataSource.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import Foundation
import SwiftData
import SpaceXDomain
import SpaceXProtocols

/// SwiftData implementation of RocketDataSource
@MainActor
final class RocketDataSource: RocketDataSourceProtocol {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveRockets(_ rockets: [Rocket]) async throws {
        // Convert domain models to SwiftData entities
        let entities = rockets.map { RocketEntity.fromDomain($0) }
        
        // Insert entities into context
        for entity in entities {
            modelContext.insert(entity)
        }
        
        // Save context
        try modelContext.save()
    }
    
    func fetchAllRockets() async throws -> [Rocket] {
        let descriptor = FetchDescriptor<RocketEntity>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        
        // Convert SwiftData entities to domain models
        return entities.map { $0.toDomain() }
    }
    
    func fetchRocket(by id: String) async throws -> Rocket? {
        let predicate = #Predicate<RocketEntity> { entity in
            entity.id == id
        }
        
        let descriptor = FetchDescriptor<RocketEntity>(predicate: predicate)
        let entities = try modelContext.fetch(descriptor)
        
        return entities.first?.toDomain()
    }
    
    func deleteRocket(by id: String) async throws {
        try modelContext.delete(model: RocketEntity.self, where: #Predicate { $0.id == id })
        try modelContext.save()
    }
    
    func clearAllRockets() async throws {
        try modelContext.delete(model: RocketEntity.self)
        try modelContext.save()
    }
}
