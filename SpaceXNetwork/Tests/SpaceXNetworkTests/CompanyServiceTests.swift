//
//  CompanyServiceTests.swift
//  SpaceXNetwork
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXNetwork
import Foundation
import SpaceXDomain
import SpaceXMocks

final class CompanyServiceTests: XCTestCase {
    
    func testFetchCompanyInfoSuccess() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("company") == true)
            XCTAssertEqual(request.httpMethod, "GET")
            
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    MockCompanyData.mockCompanyJSON)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = CompanyService(client: client, environment: SpaceXEnvironment.production)
        
        // When
        let result = try await service.fetchCompanyInfo(bypassCache: false)
        
        // Then
        XCTAssertEqual(result.name, "SpaceX")
        XCTAssertEqual(result.founder, "Elon Musk")
        XCTAssertEqual(result.founded, 2002)
        XCTAssertEqual(result.employees, 12000)
        XCTAssertEqual(result.ceo, "Elon Musk")
        XCTAssertEqual(result.headquarters.city, "Hawthorne")
    }
    
    func testFetchCompanyInfoNetworkError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            return (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data())
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = CompanyService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchCompanyInfo(bypassCache: false)
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
        let service = CompanyService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchCompanyInfo(bypassCache: false)
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
    
    func testFetchCompanyInfoTimeoutError() async throws {
        // Given
        MockURLProtocol.requestHandler = { request in
            throw URLError(.timedOut)
        }
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        let client = SpaceXAPIClient(session: session)
        let service = CompanyService(client: client, environment: SpaceXEnvironment.production)
        
        // When & Then
        do {
            _ = try await service.fetchCompanyInfo(bypassCache: false)
            XCTFail("Should have thrown error")
        } catch {
            XCTAssertTrue(error is NetworkError, "Should throw NetworkError")
        }
    }
}
