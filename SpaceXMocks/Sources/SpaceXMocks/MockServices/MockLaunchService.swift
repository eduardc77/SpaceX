//
//  MockLaunchService.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public final class MockLaunchService: LaunchServiceProtocol, @unchecked Sendable {
    public var mockPaginatedResult: PaginatedLaunches?
    public var mockAvailableYears: Set<Int> = []
    public var shouldThrowError = false
    public var error: Error = NetworkError.noData
    public var callCount = 0
    
    public init() {}
    
    public func fetchAllLaunches() async throws -> [Launch] {
        callCount += 1
        if shouldThrowError { throw error }
        return mockPaginatedResult?.launches ?? []
    }
    
    public func fetchLaunch(id: String) async throws -> Launch {
        callCount += 1
        if shouldThrowError { throw error }
        guard let launch = mockPaginatedResult?.launches.first(where: { $0.id == id }) else {
            throw NetworkError.noData
        }
        return launch
    }
    
    public func fetchLaunches(query: LaunchQuery) async throws -> PaginatedLaunches {
        callCount += 1
        if shouldThrowError { throw error }
        return mockPaginatedResult ?? PaginatedLaunches(
            launches: [], totalCount: 0, currentPage: 1, totalPages: 1,
            hasNextPage: false, hasPrevPage: false, pageSize: 20
        )
    }
    
    public func fetchUpcomingLaunches() async throws -> [Launch] {
        callCount += 1
        if shouldThrowError { throw error }
        return mockPaginatedResult?.launches.filter { $0.upcoming } ?? []
    }
    
    public func fetchPastLaunches() async throws -> [Launch] {
        callCount += 1
        if shouldThrowError { throw error }
        return mockPaginatedResult?.launches.filter { !$0.upcoming } ?? []
    }
    
    public func fetchAvailableYears() async throws -> Set<Int> {
        callCount += 1
        if shouldThrowError { throw error }
        return mockAvailableYears
    }
} 
