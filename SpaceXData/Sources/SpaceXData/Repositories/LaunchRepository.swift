//
//  LaunchRepository.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import Foundation
import SwiftData
import SpaceXDomain
import SpaceXProtocols
import SpaceXUtilities
import SpaceXNetwork

// MARK: - Internal Repository Errors
private enum LaunchRepositoryError: Error {
    case cacheEmpty
    case certificatePinningFailure
    case networkUnavailable
    case serverError(Int)
    case dataCorrupted
}

// Repository errors are now mapped to AppError internally
// No need for LaunchRepositoryError to be public

public final class LaunchRepository: LaunchRepositoryProtocol, @unchecked Sendable {
    private let launchService: LaunchServiceProtocol
    private let localDataSource: LaunchDataSourceProtocol

    // MARK: - Cache Configuration
    private let cacheExpirationInterval: TimeInterval = 5 * 60 // 5 minutes
    private var lastCacheUpdate: [String: Date] = [:]

    public init(
        launchService: LaunchServiceProtocol,
        localDataSource: LaunchDataSourceProtocol
    ) {
        self.launchService = launchService
        self.localDataSource = localDataSource
    }

    public func getLaunches(
        page: Int = 1,
        pageSize: Int = 20,
        sortOption: LaunchSortOption = .dateAscending,
        filter: LaunchFilter = LaunchFilter(),
        forceRefresh: Bool = false
    ) async throws -> PaginatedLaunches {

        // Only fetch from network if filter is ACTIVELY filtering (not empty)
        if filter.isActive {
            // Always fetch fresh filtered data
            SpaceXLogger.network("Fetching filtered results from network")
            return try await fetchFromNetworkWithFilter(
                page: page,
                pageSize: pageSize,
                sortOption: sortOption,
                filter: filter
            )
        }

        // For no filters (cleared filters), use normal caching logic
        if forceRefresh {
            SpaceXLogger.network("🔄 Force refresh - trying network first")
            do {
                // Try network first
                let sortOptions = sortOption.apiSortOptions
                let query = LaunchQuery(options: QueryOptions(limit: pageSize, page: page, sort: sortOptions))
                let result = try await launchService.fetchLaunches(query: query)

                // Network succeeded - clear old cache and save new data
                try await clearAllCaches()
                try await saveLaunchesAndUpdateCache(result.launches, sortOption: sortOption)
                return result
            } catch let networkError as NetworkError {
                // Map NetworkError to AppError
                let appError = mapNetworkErrorToAppError(networkError)
                SpaceXLogger.network("🔄 Force refresh failed: \(appError)")

                do {
                    return try await loadFromCache(page: page, pageSize: pageSize, sortOption: sortOption, filter: filter)
                } catch {
                    throw appError
                }
            } catch {
                // Other errors
                SpaceXLogger.network("🔄 Force refresh failed, using cache")
                do {
                    return try await loadFromCache(page: page, pageSize: pageSize, sortOption: sortOption, filter: filter)
                } catch {
                    throw error
                }
            }
        }

        // Check if cache exists and is valid for this sort option
        if !isCacheExpired(for: sortOption) {
            do {
                let cachedResult = try await loadFromCache(page: page, pageSize: pageSize, sortOption: sortOption, filter: filter)
                SpaceXLogger.cacheOperation("Cache hit for sort: \(sortOption.rawValue) - using cached data")
                return cachedResult
            } catch {
                SpaceXLogger.cacheOperation("⚠️ Cache miss for page \(page) with sort \(sortOption.rawValue), fetching from network")
            }
        } else {
            SpaceXLogger.cacheOperation("🔄 Cache expired for sort: \(sortOption.rawValue) - fetching from network")
        }

        // Cache miss or expired - fetch from network
        return try await refreshFromNetwork(page: page, pageSize: pageSize, sortOption: sortOption)
    }

    public func getAvailableYears() async throws -> [Int] {
        // Check cache first
        if let cachedYears = try await getCachedYears() {
            SpaceXLogger.cacheOperation("📅 Cache hit - returning \(cachedYears.count) cached years: \(cachedYears)")
            return cachedYears
        }

        SpaceXLogger.cacheOperation("📅 Cache miss - fetching years from network")
        // Fetch from network and cache
        do {
            let years = try await launchService.fetchAvailableYears()
            try await cacheYears(years)
            return years.sorted(by: >)
        } catch {
            // Network failed - return any cached years we have
            if let cachedYears = try? await localDataSource.fetchCachedYears() {
                return cachedYears.sorted(by: >)
            }
            throw error
        }
    }

    // MARK: - Private Methods

    private func loadFromCache(page: Int, pageSize: Int, sortOption: LaunchSortOption, filter: LaunchFilter) async throws -> PaginatedLaunches {
        let totalCount = try await localDataSource.getLaunchCount(filter: filter)

        guard totalCount > 0 else {
            throw AppError.networkUnavailable
        }

        let paginatedLaunches = try await localDataSource.fetchLaunches(page: page, pageSize: pageSize, sortOption: sortOption, filter: filter)

        // Throw error if no data for this page, this triggers network fetch fallback
        guard !paginatedLaunches.isEmpty else {
            throw AppError.networkUnavailable
        }

        let totalPages = Int(ceil(Double(totalCount) / Double(pageSize)))
        let hasNextPage = paginatedLaunches.count == pageSize

        SpaceXLogger.cacheOperation("Cache hit - Page \(page) for sort \(sortOption.rawValue), got \(paginatedLaunches.count) items, hasNextPage: \(hasNextPage)")
        return PaginatedLaunches(
            launches: paginatedLaunches,
            totalCount: totalCount,
            currentPage: page,
            totalPages: totalPages,
            hasNextPage: hasNextPage,
            hasPrevPage: page > 1,
            pageSize: pageSize
        )
    }

    private func refreshFromNetwork(page: Int, pageSize: Int, sortOption: LaunchSortOption) async throws -> PaginatedLaunches {
        SpaceXLogger.network("🌐 Network fetch - Page \(page) with sort: \(sortOption.rawValue) - saving to cache")
        do {
            let sortOptions = sortOption.apiSortOptions
            let query = LaunchQuery(options: QueryOptions(limit: pageSize, page: page, sort: sortOptions))
            let result = try await launchService.fetchLaunches(query: query)

            // Save new data and update cache metadata
            try await saveLaunchesAndUpdateCache(result.launches, sortOption: sortOption)

            return result
        } catch let networkError as NetworkError {
            let appError = mapNetworkErrorToAppError(networkError)
            SpaceXLogger.network("Network failed: \(appError), falling back to cache")
            do {
                return try await loadFromCache(page: page, pageSize: pageSize, sortOption: sortOption, filter: LaunchFilter())
            } catch {
                throw appError
            }
        } catch {
            SpaceXLogger.network("Network failed, falling back to cache")
            do {
                return try await loadFromCache(page: page, pageSize: pageSize, sortOption: sortOption, filter: LaunchFilter())
            } catch {
                throw error
            }
        }
    }

    private func fetchFromNetworkWithFilter(
        page: Int,
        pageSize: Int,
        sortOption: LaunchSortOption,
        filter: LaunchFilter
    ) async throws -> PaginatedLaunches {
        SpaceXLogger.network("Network fetch with filter - Page \(page)")

        // Build query based on filter
        let query = buildQuery(filter: filter, sortOption: sortOption, page: page, pageSize: pageSize)

        do {
            return try await launchService.fetchLaunches(query: query)
        } catch let networkError as NetworkError {
            // Map NetworkError to AppError
            let appError = mapNetworkErrorToAppError(networkError)
            SpaceXLogger.network("Network fetch with filter failed: \(appError)")
            throw appError
        } catch {
            // Re-throw other errors as-is
            SpaceXLogger.network("Network fetch with filter failed with unexpected error: \(error)")
            throw error
        }
    }

    // MARK: - Query Building

    private func buildQuery(
        filter: LaunchFilter,
        sortOption: LaunchSortOption,
        page: Int,
        pageSize: Int
    ) -> LaunchQuery {
        let queryFilter = LaunchQueryBuilder()
            .withYearsIfNeeded(filter.years)
            .withSuccessIfNeeded(filter.successStatus)
            .build()

        let query = LaunchQuery(
            query: queryFilter,
            options: QueryOptions(
                limit: pageSize,
                page: page,
                sort: sortOption.apiSortOptions
            )
        )

        // Validate query before returning
        do {
            try query.validate()
        } catch {
            SpaceXLogger.error("❌ Invalid query built: \(error.localizedDescription)")
            // Return query anyway but log the error - this shouldn't happen in production
        }

        return query
    }

    // MARK: - Cache Management

    private func clearAllCaches() async throws {
        try await localDataSource.clearAllLaunches()

        // Clear all sort-specific timestamps
        for sortOption in LaunchSortOption.allCases {
            clearCacheTimestamp(for: sortOption)
        }
    }

    private func saveLaunchesAndUpdateCache(_ launches: [Launch], sortOption: LaunchSortOption) async throws {
        try await localDataSource.saveLaunches(launches)
        updateCacheTimestamp(for: sortOption)
    }

    // MARK: - Error Mapping

    private func mapNetworkErrorToAppError(_ networkError: NetworkError) -> AppError {
        SpaceXLogger.error("🔍 LaunchRepository mapping NetworkError: \(networkError)")
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

    // MARK: - Year Caching

    private let yearsCacheKey = "spacex_years_cache_timestamp"
    private let yearsCacheExpiration: TimeInterval = 24 * 60 * 60 // 24 hours

    private func getCachedYears() async throws -> [Int]? {
        // Check if cache is expired
        guard let lastUpdate = UserDefaults.standard.object(forKey: yearsCacheKey) as? Date,
              Date().timeIntervalSince(lastUpdate) < yearsCacheExpiration else {
            return nil
        }

        // Fetch from data service
        return try await localDataSource.fetchCachedYears()
    }

    private func cacheYears(_ years: Set<Int>) async throws {
        try await localDataSource.saveCachedYears(Array(years))
        UserDefaults.standard.set(Date(), forKey: yearsCacheKey)
    }

    // MARK: - Cache Configuration
    private func cacheTimestampKey(for sortOption: LaunchSortOption) -> String {
        "spacex_launch_cache_timestamp_\(sortOption.rawValue)"
    }

    private func lastCacheUpdate(for sortOption: LaunchSortOption) -> Date? {
        UserDefaults.standard.object(forKey: cacheTimestampKey(for: sortOption)) as? Date
    }

    private func updateCacheTimestamp(for sortOption: LaunchSortOption) {
        UserDefaults.standard.set(Date(), forKey: cacheTimestampKey(for: sortOption))
    }

    private func clearCacheTimestamp(for sortOption: LaunchSortOption) {
        UserDefaults.standard.removeObject(forKey: cacheTimestampKey(for: sortOption))
    }

    private func isCacheExpired(for sortOption: LaunchSortOption) -> Bool {
        guard let lastUpdate = lastCacheUpdate(for: sortOption) else { return true }
        return Date().timeIntervalSince(lastUpdate) > cacheExpirationInterval
    }
}
