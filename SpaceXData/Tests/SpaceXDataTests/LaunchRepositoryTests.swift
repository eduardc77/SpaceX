//
//  LaunchRepositoryTests.swift
//  SpaceXData
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXData
import SpaceXDomain
import SpaceXNetwork
import SpaceXMocks

final class LaunchRepositoryTests: XCTestCase {
    var sut: LaunchRepository!
    var mockLaunchService: MockLaunchService!
    var mockLocalDataSource: MockLaunchDataSource!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockLaunchService = MockLaunchService()
        mockLocalDataSource = MockLaunchDataSource()
        
        sut = LaunchRepository(
            launchService: mockLaunchService,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDown() {
        sut = nil
        mockLaunchService = nil
        mockLocalDataSource = nil
        super.tearDown()
    }
    
    // MARK: - Caching Behavior
    
    func testCacheHitWithin15Minutes() async throws {
        // Given
        let launches = createMockLaunches()
        let paginatedResult = createPaginatedResult(launches: launches)
        mockLaunchService.mockPaginatedResult = paginatedResult
        mockLocalDataSource.mockLaunches = launches
        mockLocalDataSource.mockLaunchCount = launches.count
        
        // First fetch - loads from network and saves to cache
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // When
        mockLaunchService.callCount = 0
        mockLocalDataSource.fetchLaunchesCallCount = 0
        let result = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // Then
        XCTAssertEqual(mockLaunchService.callCount, 0, "Should use cache")
        XCTAssertGreaterThan(mockLocalDataSource.fetchLaunchesCallCount, 0, "Should fetch from cache")
        XCTAssertEqual(result.launches.count, launches.count, "Should return cached data")
    }
    
    func testForceRefreshBypassesCache() async throws {
        // Given
        let launches = createMockLaunches()
        let paginatedResult = createPaginatedResult(launches: launches)
        mockLaunchService.mockPaginatedResult = paginatedResult
        mockLocalDataSource.mockLaunches = launches
        
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // When
        mockLaunchService.callCount = 0
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: true
        )
        
        // Then
        XCTAssertEqual(mockLaunchService.callCount, 1, "Should bypass cache on force refresh")
    }
    
    func testDifferentSortOptionsUseSeparateCaches() async throws {
        // Given
        let launches = createMockLaunches()
        let paginatedResult = createPaginatedResult(launches: launches)
        mockLaunchService.mockPaginatedResult = paginatedResult
        mockLocalDataSource.mockLaunches = launches
        mockLocalDataSource.mockLaunchCount = launches.count
        
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // When
        mockLaunchService.callCount = 0
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateAscending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // Then
        XCTAssertEqual(mockLaunchService.callCount, 1, "Different sort options should have separate caches")
    }
    
    // MARK: - Offline Behavior
    
    func testOfflineFallbackToCache() async throws {
        // Given
        let launches = createMockLaunches()
        let paginatedResult = createPaginatedResult(launches: launches)
        mockLaunchService.mockPaginatedResult = paginatedResult
        mockLocalDataSource.mockLaunches = launches
        mockLocalDataSource.mockLaunchCount = launches.count
        
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // When
        mockLaunchService.shouldThrowError = true
        mockLaunchService.error = NetworkError.networkError(URLError(.notConnectedToInternet))
        
        let result = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: true
        )
        
        // Then
        XCTAssertEqual(result.launches.count, launches.count, "Should return cached data when offline")
    }
    
    func testOfflineWithNoCacheThrowsError() async {
        // Given
        mockLaunchService.shouldThrowError = true
        mockLaunchService.error = NetworkError.networkError(URLError(.notConnectedToInternet))
        mockLocalDataSource.shouldThrowError = true
        // When/Then: Should throw error
        do {
            _ = try await sut.getLaunches(
                page: 1, pageSize: 20, sortOption: .dateDescending,
                filter: LaunchFilter(), forceRefresh: false
            )
            XCTFail("Should have thrown error when no cache and offline")
        } catch {
            XCTAssertTrue(error is AppError, "Should throw AppError when no cache available")
        }
    }
    
    // MARK: - Filter Handling
    
    func testFilteredRequestsAlwaysCallNetwork() async throws {
        // Given
        let launches = createMockLaunches()
        let paginatedResult = createPaginatedResult(launches: launches)
        mockLaunchService.mockPaginatedResult = paginatedResult
        mockLocalDataSource.mockLaunches = launches
        mockLocalDataSource.mockLaunchCount = launches.count
        
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: LaunchFilter(), forceRefresh: false
        )
        
        // When
        mockLaunchService.callCount = 0
        let filter = LaunchFilter(successStatus: .successful)
        _ = try await sut.getLaunches(
            page: 1, pageSize: 20, sortOption: .dateDescending,
            filter: filter, forceRefresh: false
        )
        
        // Then
        XCTAssertEqual(mockLaunchService.callCount, 1, "Filtered requests should always hit network")
    }
    
    // MARK: - Years Functionality
    
    func testAvailableYearsSuccess() async throws {
        // Given
        mockLaunchService.mockAvailableYears = Set([2020, 2021, 2022, 2023, 2024])
        mockLocalDataSource.mockCachedYears = nil // No cache initially
        
        // When
        let years = try await sut.getAvailableYears()
        
        // Then
        XCTAssertEqual(years, [2024, 2023, 2022, 2021, 2020], "Should sort years newest first")
        XCTAssertEqual(mockLaunchService.callCount, 1, "Should call network service")
    }
    
    func testAvailableYearsUsesCache() async throws {
        // Given
        mockLocalDataSource.mockCachedYears = [2024, 2023, 2022]
        
        // When
        let years = try await sut.getAvailableYears()
        
        // Then
        XCTAssertEqual(years, [2024, 2023, 2022], "Should return cached years")
        XCTAssertEqual(mockLaunchService.callCount, 0, "Should not call network when cache available")
    }
    
    // MARK: - Helper Methods
    
    private func createMockLaunches() -> [Launch] {
        return Array(MockLaunchData.launches.prefix(5)) // Use first 5 mock launches for testing
    }
    
    private func createPaginatedResult(launches: [Launch]) -> PaginatedLaunches {
        return PaginatedLaunches(
            launches: launches, totalCount: launches.count, currentPage: 1,
            totalPages: 1, hasNextPage: false, hasPrevPage: false, pageSize: 20
        )
    }
}
