//
//  MockRocketDataSource.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public class MockRocketDataSource: RocketDataSourceProtocol {
    public var mockRockets: [Rocket] = []
    public var mockSingleRocket: Rocket?
    public var shouldThrowError = false
    public var error: Error = NSError(domain: "Test", code: 1, userInfo: nil)

    public var saveCallCount = 0
    public var fetchAllCallCount = 0
    public var fetchSingleCallCount = 0

    public init() {}

    public func saveRockets(_ rockets: [Rocket]) async throws {
        saveCallCount += 1
        if shouldThrowError { throw error }
        mockRockets.append(contentsOf: rockets)
    }

    public func fetchAllRockets() async throws -> [Rocket] {
        fetchAllCallCount += 1
        if shouldThrowError { throw error }
        return mockRockets
    }

    public func fetchRocket(by id: String) async throws -> Rocket? {
        fetchSingleCallCount += 1
        if shouldThrowError { throw error }
        return mockSingleRocket ?? mockRockets.first { $0.id == id }
    }

    public func deleteRocket(by id: String) async throws {
        if shouldThrowError { throw error }
        mockRockets.removeAll { $0.id == id }
    }

    public func clearAllRockets() async throws {
        if shouldThrowError { throw error }
        mockRockets.removeAll()
    }
}
