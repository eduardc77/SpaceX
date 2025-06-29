//
//  RocketRepositoryTests.swift
//  SpaceXData
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXData
import SpaceXDomain
import SpaceXNetwork
import SpaceXMocks

final class RocketRepositoryTests: XCTestCase {
    var sut: RocketRepository!
    var mockNetworkService: MockRocketService!
    var mockLocalDataSource: MockRocketDataSource!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockNetworkService = MockRocketService()
        mockLocalDataSource = MockRocketDataSource()
        
        sut = RocketRepository(
            networkService: mockNetworkService,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockLocalDataSource = nil
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "spacex_rocket_cache_timestamp")
        super.tearDown()
    }
    
    // MARK: - Get All Rocket Names Tests
    
    func testGetAllRocketNamesFromCache() async throws {
        // Given
        let rockets = MockRocketData.mockRockets
        mockLocalDataSource.mockRockets = rockets
        
        // When: Get all rocket names
        let result = try await sut.getAllRocketNames(forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockNetworkService.callCount, 0, "Should use cache")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[MockRocketData.falcon9.id], "Falcon 9")
        XCTAssertEqual(result[MockRocketData.falconHeavy.id], "Falcon Heavy")
    }
    
    func testGetAllRocketNamesFromNetwork() async throws {
        // Given
        let rockets = MockRocketData.mockRockets
        mockLocalDataSource.mockRockets = []
        mockNetworkService.mockRockets = rockets
        
        // When
        let result = try await sut.getAllRocketNames(forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockNetworkService.callCount, 1, "Should call network when cache empty")
        XCTAssertEqual(mockLocalDataSource.saveCallCount, 1, "Should save to cache")
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[MockRocketData.falcon9.id], "Falcon 9")
    }
    
    // MARK: - Get Specific Rocket Names Tests
    
    func testGetRocketNamesPartialCache() async throws {
        // Given
        let cachedRocket = MockRocketData.falcon9
        let networkRocket = MockRocketData.falconHeavy
        
        mockLocalDataSource.mockRockets = [cachedRocket]
        mockNetworkService.mockSingleRocket = networkRocket
        
        // When
        let result = try await sut.getRocketNames(for: [cachedRocket.id, networkRocket.id])
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[cachedRocket.id], "Falcon 9")
        XCTAssertEqual(result[networkRocket.id], "Falcon Heavy")
        XCTAssertEqual(mockNetworkService.fetchSingleCallCount, 1, "Should fetch missing rocket")
    }
    
    func testGetRocketNamesEmptyArray() async throws {
        // When
        let result = try await sut.getRocketNames(for: [])
        
        // Then
        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(mockNetworkService.callCount, 0, "Should not call network for empty array")
    }
    
    // MARK: - Get Single Rocket Tests
    
    func testGetRocketFromCache() async throws {
        // Given
        let rocket = MockRocketData.falcon9
        mockLocalDataSource.mockSingleRocket = rocket
        
        // When: Get single rocket
        let result = try await sut.getRocket(id: rocket.id)
        
        // Then
        XCTAssertEqual(result?.name, "Falcon 9")
        XCTAssertEqual(mockNetworkService.fetchSingleCallCount, 0, "Should use cache")
    }
    
    func testGetRocketFromNetwork() async throws {
        // Given
        let rocket = MockRocketData.falcon9
        mockLocalDataSource.mockSingleRocket = nil
        mockNetworkService.mockSingleRocket = rocket
        
        // When
        let result = try await sut.getRocket(id: rocket.id)
        
        // Then
        XCTAssertEqual(result?.name, "Falcon 9")
        XCTAssertEqual(mockNetworkService.fetchSingleCallCount, 1, "Should call network")
        XCTAssertEqual(mockLocalDataSource.saveCallCount, 1, "Should save to cache")
    }
    
    func testGetRocketNetworkFailureReturnsNil() async throws {
        // Given
        mockLocalDataSource.mockSingleRocket = nil
        mockNetworkService.shouldThrowError = true
        
        // When
        let result = try await sut.getRocket(id: "nonexistent")
        
        // Then
        XCTAssertNil(result)
    }
    
    
}
