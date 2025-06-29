//
//  RocketRepository.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols
import SpaceXUtilities

public enum RocketRepositoryError: Error {
    case cacheEmpty
    case certificatePinningFailure
    case networkUnavailable
    case serverError(Int)
    case dataCorrupted
}

public final class RocketRepository: RocketRepositoryProtocol, @unchecked Sendable {
    private let networkService: RocketServiceProtocol
    private let localDataSource: RocketDataSourceProtocol
    
    // MARK: - Cache Configuration
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let cacheTimestampKey = "spacex_rocket_cache_timestamp"
    
    private var lastCacheUpdate: Date? {
        get { UserDefaults.standard.object(forKey: cacheTimestampKey) as? Date }
        set { 
            if let date = newValue {
                UserDefaults.standard.set(date, forKey: cacheTimestampKey)
            } else {
                UserDefaults.standard.removeObject(forKey: cacheTimestampKey)
            }
        }
    }
    
    public init(
        networkService: RocketServiceProtocol,
        localDataSource: RocketDataSourceProtocol
    ) {
        self.networkService = networkService
        self.localDataSource = localDataSource
    }
    
    public func getAllRocketNames(forceRefresh: Bool = false) async throws -> [String: String] {
        let cachedRockets = try await localDataSource.fetchAllRockets()
        
        // Use cache if available and not expired
        if !cachedRockets.isEmpty {
            if lastCacheUpdate == nil {
                // If its first time initialize timestamp and use cache
                updateCacheTimestamp()
                SpaceXLogger.cacheOperation("Rockets loaded from cache (\(cachedRockets.count) items)")
                return Dictionary(uniqueKeysWithValues: cachedRockets.map { ($0.id, $0.name) })
            } else if !isCacheExpired() {
                SpaceXLogger.cacheOperation("Rockets loaded from cache (\(cachedRockets.count) items)")
                return Dictionary(uniqueKeysWithValues: cachedRockets.map { ($0.id, $0.name) })
            }
        }
        
        let allRockets = try await networkService.fetchAllRockets()
        try await localDataSource.saveRockets(allRockets)
        updateCacheTimestamp()
        
        SpaceXLogger.network("Rockets loaded from network (\(allRockets.count) items)")
        
        return Dictionary(uniqueKeysWithValues: allRockets.map { ($0.id, $0.name) })
    }
    
    public func getRocketNames(for rocketIds: [String]) async throws -> [String: String] {
        guard !rocketIds.isEmpty else { return [:] }
        
        var rocketNames: [String: String] = [:]
        
        for rocketId in rocketIds {
            if let cached = try? await localDataSource.fetchRocket(by: rocketId) {
                rocketNames[rocketId] = cached.name
            }
        }
        
        let missingIds = rocketIds.filter { rocketNames[$0] == nil }
        
        // Fetch missing rockets in parallel
        if !missingIds.isEmpty {
            let missingRockets = try await fetchRocketsInParallel(ids: missingIds, using: networkService)
            try await localDataSource.saveRockets(missingRockets)
            updateCacheTimestamp()
            
            for rocket in missingRockets {
                rocketNames[rocket.id] = rocket.name
            }
        }
        
        return rocketNames
    }
    
    public func getRocket(id: String) async throws -> Rocket? {
        if let cached = try? await localDataSource.fetchRocket(by: id) {
            return cached
        }
        
        do {
            let rocket = try await networkService.fetchRocket(id: id)
            try await localDataSource.saveRockets([rocket])
            updateCacheTimestamp()
            return rocket
        } catch {
            return nil
        }
    }
    
    // MARK: - Private Methods
    
    nonisolated private func fetchRocketsInParallel(
        ids: [String], 
        using service: RocketServiceProtocol
    ) async throws -> [Rocket] {
        return try await withThrowingTaskGroup(of: Rocket?.self) { group in
            var rockets: [Rocket] = []
            
            for rocketId in ids {
                group.addTask {
                    return try? await service.fetchRocket(id: rocketId)
                }
            }
            
            for try await rocket in group {
                if let rocket = rocket {
                    rockets.append(rocket)
                }
            }
            
            return rockets
        }
    }
    
    // MARK: - Cache Management
    
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastCacheUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheExpirationInterval
    }
    
    private func updateCacheTimestamp() {
        lastCacheUpdate = Date()
    }
} 
