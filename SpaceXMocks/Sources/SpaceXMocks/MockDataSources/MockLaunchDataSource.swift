//
//  MockLaunchDataSource.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public class MockLaunchDataSource: LaunchDataSourceProtocol {
    public var mockLaunches: [Launch] = []
    public var mockLaunchCount: Int = 0
    public var mockCachedYears: [Int]?
    public var shouldThrowError = false
    public var error: Error = NetworkError.networkError(URLError(.notConnectedToInternet))
    public var fetchLaunchesCallCount = 0
    
    public init() {}
    
    public func saveLaunches(_ launches: [Launch]) async throws {
        if shouldThrowError { throw error }
        mockLaunches = launches
    }
    
    public func fetchAllLaunches() async throws -> [Launch] {
        if shouldThrowError { throw error }
        return mockLaunches
    }
    
    public func fetchLaunches(page: Int, pageSize: Int, sortOption: LaunchSortOption, filter: LaunchFilter) async throws -> [Launch] {
        fetchLaunchesCallCount += 1
        if shouldThrowError { throw error }
        return mockLaunches
    }
    
    public func fetchLaunch(by id: String) async throws -> Launch? {
        if shouldThrowError { throw error }
        return mockLaunches.first { $0.id == id }
    }
    
    public func deleteLaunch(by id: String) async throws {
        if shouldThrowError { throw error }
        mockLaunches.removeAll { $0.id == id }
    }
    
    public func clearAllLaunches() async throws {
        if shouldThrowError { throw error }
        mockLaunches.removeAll()
    }
    
    public func getLaunchCount(filter: LaunchFilter) async throws -> Int {
        if shouldThrowError { throw error }
        return mockLaunchCount
    }
    
    public func saveCachedYears(_ years: [Int]) async throws {
        if shouldThrowError { throw error }
        mockCachedYears = years
    }
    
    public func fetchCachedYears() async throws -> [Int]? {
        if shouldThrowError { throw error }
        return mockCachedYears
    }
} 
