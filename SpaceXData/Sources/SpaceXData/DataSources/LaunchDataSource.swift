//
//  LaunchDataSource.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import Foundation
import SpaceXDomain
import SpaceXProtocols

/// SwiftData implementation of LaunchDataSource
@MainActor
final class LaunchDataSource: LaunchDataSourceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveLaunches(_ launches: [Launch]) async throws {
        // Fetch all existing launches in one query
        let launchIds = launches.map { $0.id }
        let predicate = #Predicate<LaunchEntity> { entity in
            launchIds.contains(entity.id)
        }
        let descriptor = FetchDescriptor<LaunchEntity>(predicate: predicate)
        let existingEntities = try modelContext.fetch(descriptor)
        
        // Create a dictionary for O(1) lookup
        let existingEntitiesById = Dictionary(uniqueKeysWithValues: existingEntities.map { ($0.id, $0) })
        
        // Process all launches
        for launch in launches {
            if let existingEntity = existingEntitiesById[launch.id] {
                // Update existing entity
                existingEntity.updateFromDomain(launch)
            } else {
                // Insert new entity
                let newEntity = LaunchEntity.fromDomain(launch)
                modelContext.insert(newEntity)
            }
        }
        
        try modelContext.save()
    }
    
    func fetchAllLaunches() async throws -> [Launch] {
        let descriptor = FetchDescriptor<LaunchEntity>(
            sortBy: [SortDescriptor(\.dateUtc, order: .forward)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func fetchLaunches(page: Int, pageSize: Int, sortOption: LaunchSortOption, filter: LaunchFilter) async throws -> [Launch] {
        let sortDescriptors = getSortDescriptors(for: sortOption)
        
        var descriptor = FetchDescriptor<LaunchEntity>(sortBy: sortDescriptors)
        descriptor.fetchLimit = pageSize
        descriptor.fetchOffset = (page - 1) * pageSize
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func getSortDescriptors(for sortOption: LaunchSortOption) -> [SortDescriptor<LaunchEntity>] {
        switch sortOption {
        case .dateAscending:
            return [SortDescriptor(\.dateUtc, order: .forward)]
        case .dateDescending:
            return [SortDescriptor(\.dateUtc, order: .reverse)]
        case .nameAscending:
            return [SortDescriptor(\.name, order: .forward)]
        case .nameDescending:
            return [SortDescriptor(\.name, order: .reverse)]
        }
    }
    
    func fetchLaunch(by id: String) async throws -> Launch? {
        let predicate = #Predicate<LaunchEntity> { entity in
            entity.id == id
        }
        
        let descriptor = FetchDescriptor<LaunchEntity>(predicate: predicate)
        let entities = try modelContext.fetch(descriptor)
        
        return entities.first?.toDomain()
    }
    
    func deleteLaunch(by id: String) async throws {
        try modelContext.delete(model: LaunchEntity.self, where: #Predicate { $0.id == id })
        try modelContext.save()
    }
    
    func clearAllLaunches() async throws {
        try modelContext.delete(model: LaunchEntity.self)
        try modelContext.save()
    }
    
    func getLaunchCount(filter: LaunchFilter) async throws -> Int {
        let descriptor = FetchDescriptor<LaunchEntity>()
        return try modelContext.fetchCount(descriptor)
    }
    
    func saveCachedYears(_ years: [Int]) async throws {
        // Clear existing years
        try modelContext.delete(model: LaunchYearEntity.self)

        // Insert new years
        for year in years {
            let yearEntity = LaunchYearEntity(year: year)
            modelContext.insert(yearEntity)
        }
        
        try modelContext.save()
    }
    
    func fetchCachedYears() async throws -> [Int]? {
        let descriptor = FetchDescriptor<LaunchYearEntity>(
            sortBy: [SortDescriptor(\.year, order: .reverse)]
        )
        let entities = try modelContext.fetch(descriptor)
        
        guard !entities.isEmpty else { return nil }
        
        return entities.map(\.year)
    }
}
