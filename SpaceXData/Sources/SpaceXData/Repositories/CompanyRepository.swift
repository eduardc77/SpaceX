//
//  CompanyRepository.swift
//  SpaceXData
//
//  Created by User on 6/22/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols
import SpaceXUtilities
import SpaceXNetwork

// MARK: - Internal Repository Errors
private enum CompanyRepositoryError: Error, Equatable {
    case cacheEmpty
    case certificatePinningFailure
    case networkUnavailable
    case serverError(Int)
    case dataCorrupted
}

public final class CompanyRepository: CompanyRepositoryProtocol, @unchecked Sendable {
    private let networkService: CompanyServiceProtocol
    private let localDataSource: CompanyDataSourceProtocol
    
    // MARK: - Cache Configuration
    private let cacheExpirationInterval: TimeInterval = 15 * 60 // 15 minutes
    private let cacheTimestampKey = "spacex_company_cache_timestamp"
    
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
        networkService: CompanyServiceProtocol,
        localDataSource: CompanyDataSourceProtocol
    ) {
        self.networkService = networkService
        self.localDataSource = localDataSource
    }
    
    public func getCompany(forceRefresh: Bool = false) async throws -> Company? {
        
        // Try cache first unless forced refresh or cache expired
        if !forceRefresh && !isCacheExpired() {
            if let cached = try? await localDataSource.fetchCompany() {
                SpaceXLogger.cacheOperation("Cache HIT - returning cached company data")
                return cached
            } else {
                SpaceXLogger.cacheOperation("Cache MISS - fetching company data from network")
            }
        }
        
        if forceRefresh {
            SpaceXLogger.network("Force refresh - fetching from network")
        } else {
            SpaceXLogger.cacheOperation("Cache EXPIRED - fetching company data from network")
        }
        
        // Fetch from network and cache
        do {
            let company = try await networkService.fetchCompanyInfo(bypassCache: forceRefresh)
            try await localDataSource.saveCompany(company)
            updateCacheTimestamp()
            return company
        } catch let networkError as NetworkError {
            // Map NetworkError to AppError
            let appError = mapNetworkErrorToAppError(networkError)
            SpaceXLogger.error("Network failed with mapped error: \(appError)")
            
            // For force refresh with network errors, throw the error
            // This ensures certificate pinning failures are properly reported
            if forceRefresh && appError.isCertificatePinningFailure {
                throw appError
            }
            
            // For all other errors (including force refresh), try cache fallback
            SpaceXLogger.network("Falling back to cached data...")
            if let cached = try? await localDataSource.fetchCompany() {
                SpaceXLogger.cacheOperation("Returning cached fallback: \(cached.name)")
                return cached
            } else {
                // No cache available, throw the error
                throw appError
            }
        } catch {
            SpaceXLogger.error("Network failed with unexpected error: \(error)")
            
            // For non-NetworkError, try cache fallback
            if !forceRefresh, let cached = try? await localDataSource.fetchCompany() {
                SpaceXLogger.cacheOperation("Returning cached fallback: \(cached.name)")
                return cached
            }
            
            // Re-throw the original error
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func isCacheExpired() -> Bool {
        guard let lastUpdate = lastCacheUpdate else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheExpirationInterval
    }
    
    private func updateCacheTimestamp() {
        lastCacheUpdate = Date()
    }
    
    // MARK: - Error Mapping
    
    private func mapNetworkErrorToAppError(_ networkError: NetworkError) -> AppError {
        SpaceXLogger.error("🔍 CompanyRepository mapping NetworkError: \(networkError)")
        SpaceXLogger.error("   Is certificate pinning failure: \(networkError.isCertificatePinningFailure)")
        
        if networkError.isCertificatePinningFailure {
            return .certificatePinningFailure
        }
        
        switch networkError {
        case .networkError:
            return .networkUnavailable
        case .httpError(let code):
            return .serverError(code)
        case .decodingError:
            return .dataCorrupted
        case .invalidURL, .noData:
            return .networkUnavailable
        }
    }
}
