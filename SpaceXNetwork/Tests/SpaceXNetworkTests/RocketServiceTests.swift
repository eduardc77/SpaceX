//
//  RocketServiceTests.swift
//  SpaceXNetwork
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXNetwork
import Foundation
import SpaceXDomain
import SpaceXMocks

final class RocketServiceTests: XCTestCase {
    
    func testFetchAllRocketsSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("rockets") == true)
            XCTAssertEqual(request.httpMethod, "GET")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    MockRocketData.mockRocketsJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = RocketService(client: client, environment: SpaceXEnvironment.production)
        
        // When
        let result = try await service.fetchAllRockets()
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "Falcon 9")
        XCTAssertEqual(result[0].active, true)
        XCTAssertEqual(result[1].name, "Falcon Heavy")
        XCTAssertEqual(result[1].successRatePct, 100)
    }
    
    func testFetchSingleRocketSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("rockets/rocket1") == true)
            XCTAssertEqual(request.httpMethod, "GET")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    MockRocketData.mockRocketJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = RocketService(client: client, environment: SpaceXEnvironment.production)
        
        // When
        let result = try await service.fetchRocket(id: "rocket1")
        
        // Then
        XCTAssertEqual(result.id, "rocket1")
        XCTAssertEqual(result.name, "Falcon 9")
        XCTAssertEqual(result.active, true)
        XCTAssertEqual(result.costPerLaunch, 62000000)
        XCTAssertEqual(result.successRatePct, 97)
    }
    
    func testFetchRocketNetworkError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!,
                    Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = RocketService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchRocket(id: "nonexistent")
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
    
    func testFetchRocketTimeoutError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            throw URLError(.networkConnectionLost)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = RocketService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchAllRockets()
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
    
    func testAPIClientNetworkMonitoringThrowsWhenOffline() async throws {
        // Given
        let mockNetworkMonitor = await MockNetworkMonitor()
        await mockNetworkMonitor.simulateNetworkUnavailable()
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session, networkMonitor: mockNetworkMonitor)
        let service = RocketService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchAllRockets()
            XCTFail("Should have thrown error due to no network")
        } catch let error as NetworkError {
            // Should throw NetworkError.networkError with URLError.notConnectedToInternet
            switch error {
            case .networkError(let urlError):
                XCTAssertEqual((urlError as? URLError)?.code, .notConnectedToInternet)
            default:
                XCTFail("Should throw NetworkError.networkError(.notConnectedToInternet)")
            }
        } catch {
            XCTFail("Should throw NetworkError, got \(error)")
        }
    }
}
