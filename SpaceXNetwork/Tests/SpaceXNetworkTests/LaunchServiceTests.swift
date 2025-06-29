//
//  LaunchServiceTests.swift
//  SpaceXNetwork
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXNetwork
import Foundation
import SpaceXMocks
import SpaceXDomain

final class LaunchServiceTests: XCTestCase {
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    func testFetchLaunchesSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("launches/query") == true)
            XCTAssertEqual(request.httpMethod, "POST")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    MockLaunchData.mockPaginatedLaunchesJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = LaunchService(client: client, environment: SpaceXEnvironment.production)
        
        // When
        let query = LaunchQuery(options: QueryOptions(limit: 20, page: 1))
        let result = try await service.fetchLaunches(query: query)
        
        // Then
        XCTAssertEqual(result.launches.count, 2)
        XCTAssertEqual(result.totalCount, 200)
        XCTAssertEqual(result.currentPage, 1)
        XCTAssertEqual(result.totalPages, 10)
        XCTAssertTrue(result.hasNextPage)
        XCTAssertFalse(result.hasPrevPage)
        
        // Check first launch
        let firstLaunch = result.launches[0]
        XCTAssertEqual(firstLaunch.name, "Falcon Heavy Test Flight")
        XCTAssertEqual(firstLaunch.success, true)
        XCTAssertEqual(firstLaunch.flightNumber, 64)
    }
    
    func testFetchAvailableYearsSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("launches/query") == true)
            XCTAssertEqual(request.httpMethod, "POST")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    MockLaunchData.mockYearsJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = LaunchService(client: client, environment: SpaceXEnvironment.production)
        
        // When
        let result = try await service.fetchAvailableYears()
        
        // Then
        XCTAssertTrue(result.contains(2024))
        XCTAssertTrue(result.contains(2023))
        XCTAssertTrue(result.contains(2022))
        XCTAssertEqual(result.count, 3)
    }
    
    func testFetchLaunchesNetworkError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = LaunchService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            let query = LaunchQuery(options: QueryOptions(limit: 20, page: 1))
            _ = try await service.fetchLaunches(query: query)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
    
    func testFetchLaunchesTimeoutError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            throw URLError(.timedOut)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = LaunchService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            let query = LaunchQuery(options: QueryOptions(limit: 20, page: 1))
            _ = try await service.fetchLaunches(query: query)
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
        let service = LaunchService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            let query = LaunchQuery(options: QueryOptions(limit: 20, page: 1))
            _ = try await service.fetchLaunches(query: query)
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
