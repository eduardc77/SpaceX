//
//  MockRocketRepository.swift
//  SpaceXMocks
//
//  Created by User on 6/24/25.
//

import Foundation
import SpaceXDomain

public class MockRocketRepository: RocketRepositoryProtocol {
    public var shouldThrowError = false
    public var delay: TimeInterval = 0.3
    
    // Mock rocket names mapping
    private let rocketNames: [String: String] = [
        "5e9d0d95eda69973a809d1ec": "Falcon Heavy",
        "5e9d0d95eda69955f7f4c6a8": "Falcon 1",
        "5e9d0d96eda699382d09d1ee": "Starship"
    ]
    
    public init() {}
    
    public func getAllRocketNames(forceRefresh: Bool = false) async throws -> [String: String] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }
        
        return rocketNames
    }
    
    public func getRocketNames(for rocketIds: [String]) async throws -> [String: String] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }
        
        var result: [String: String] = [:]
        for rocketId in rocketIds {
            result[rocketId] = rocketNames[rocketId] ?? "Unknown Rocket"
        }
        
        return result
    }
    
    public func getRocket(id: String) async throws -> Rocket? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }

        return nil
    }
}
