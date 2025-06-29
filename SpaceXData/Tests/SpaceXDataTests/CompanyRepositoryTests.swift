//
//  CompanyRepositoryTests.swift
//  SpaceXData
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceXData
import SpaceXDomain
import SpaceXMocks
import SpaceXNetwork

final class CompanyRepositoryTests: XCTestCase {
    var sut: CompanyRepository!
    var mockNetworkService: MockCompanyService!
    var mockLocalDataSource: MockCompanyDataSource!
    
    override func setUp() async throws {
        try await super.setUp()
        
        mockNetworkService = MockCompanyService()
        mockLocalDataSource = MockCompanyDataSource()
        
        sut = CompanyRepository(
            networkService: mockNetworkService,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDown() {
        sut = nil
        mockNetworkService = nil
        mockLocalDataSource = nil
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: "spacex_company_cache_timestamp")
        super.tearDown()
    }
    
    // MARK: - Cache Hit Tests
    
    func testCacheHitWithin24Hours() async throws {
        // Given
        let company = MockCompanyData.spacex
        mockLocalDataSource.mockCompany = company
        
        // Set cache timestamp to now (within 24 hours)
        UserDefaults.standard.set(Date(), forKey: "spacex_company_cache_timestamp")
        
        // When
        let result = try await sut.getCompany(forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockNetworkService.callCount, 0, "Should use cache")
        XCTAssertEqual(mockLocalDataSource.fetchCallCount, 1, "Should fetch from cache")
        XCTAssertEqual(result?.name, company.name)
    }
    
    func testForceRefreshBypassesCache() async throws {
        // Given
        let cachedCompany = MockCompanyData.create(name: "Cached SpaceX")
        let networkCompany = MockCompanyData.create(name: "Fresh SpaceX")
        
        mockLocalDataSource.mockCompany = cachedCompany
        mockNetworkService.mockCompany = networkCompany
        
        // When
        let result = try await sut.getCompany(forceRefresh: true)
        
        // Then
        XCTAssertEqual(mockNetworkService.callCount, 1, "Should bypass cache on force refresh")
        XCTAssertEqual(result?.name, networkCompany.name, "Should return fresh data")
    }
    
    // MARK: - Cache Miss Tests
    
    func testCacheMissCallsNetwork() async throws {
        // Given
        let networkCompany = MockCompanyData.spacex
        mockLocalDataSource.mockCompany = nil
        mockNetworkService.mockCompany = networkCompany
        
        // When
        let result = try await sut.getCompany(forceRefresh: false)
        
        // Then
        XCTAssertEqual(mockNetworkService.callCount, 1, "Should call network when cache empty")
        XCTAssertEqual(mockLocalDataSource.saveCallCount, 1, "Should save to cache")
        XCTAssertEqual(result?.name, networkCompany.name)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkFailureFallsBackToCache() async throws {
        // Given
        let cachedCompany = MockCompanyData.create(name: "Cached Company")
        mockLocalDataSource.mockCompany = cachedCompany
        mockNetworkService.shouldThrowError = true
        mockNetworkService.error = NetworkError.networkError(URLError(.notConnectedToInternet))
        
        
        
        // When
        let result = try await sut.getCompany(forceRefresh: true)
        
        // Then
        XCTAssertEqual(result?.name, cachedCompany.name, "Should fallback to cache when network fails")
        XCTAssertEqual(mockLocalDataSource.fetchCallCount, 1, "Should fetch from cache as fallback")
    }
    
    func testNetworkFailureWithNoCacheThrowsError() async throws {
        // Given
        mockLocalDataSource.mockCompany = nil
        mockNetworkService.shouldThrowError = true
        mockNetworkService.error = NetworkError.networkError(URLError(.notConnectedToInternet))
        
        
        
        // When & Then
        do {
            _ = try await sut.getCompany(forceRefresh: false)
            XCTFail("Should throw error when no cache and network fails")
        } catch let error as AppError {
            XCTAssertEqual(error, .networkUnavailable, "Should throw networkUnavailable error")
        } catch {
            XCTFail("Should throw AppError, got \(error)")
        }
    }
    
    
    
    
}
