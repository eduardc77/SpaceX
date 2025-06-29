//
//  MockRocketService.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public final class MockRocketService: RocketServiceProtocol, @unchecked Sendable {
    public var mockRockets: [Rocket] = []
    public var mockSingleRocket: Rocket?
    public var shouldThrowError = false
    public var error: Error = NetworkError.networkError(URLError(.networkConnectionLost))

    public var callCount = 0
    public var fetchSingleCallCount = 0

    public init() {}
    
    public func fetchAllRockets() async throws -> [Rocket] {
        callCount += 1
        if shouldThrowError { throw error }
        return mockRockets
    }

    public func fetchRocket(id: String) async throws -> Rocket {
        fetchSingleCallCount += 1
        if shouldThrowError { throw error }
        guard let rocket = mockSingleRocket else {
            throw NetworkError.httpError(404)
        }
        return rocket
    }
} 
