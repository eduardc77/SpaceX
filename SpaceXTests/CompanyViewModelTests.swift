//
//  CompanyViewModelTests.swift
//  SpaceXTests
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceX
import SpaceXDomain
import SpaceXMocks

@MainActor
final class CompanyViewModelTests: XCTestCase {
    var sut: CompanyViewModel!
    var mockCompanyRepo: MockCompanyRepository!
    
    override func setUp() {
        super.setUp()
        mockCompanyRepo = MockCompanyRepository()
        sut = CompanyViewModel(companyRepository: mockCompanyRepo)
    }
    
    override func tearDown() {
        sut = nil
        mockCompanyRepo = nil
        super.tearDown()
    }
    
    func testInitialLoadSuccess() async {
        // Given
        mockCompanyRepo.shouldThrowError = false
        
        // When
        await sut.loadCompany()
        
        // Then
        XCTAssertNotNil(sut.company, "Should load company data")
        XCTAssertFalse(sut.isLoading, "Should finish loading")
        XCTAssertNil(sut.errorMessage, "Should have no error")
        
        XCTAssertEqual(sut.company?.name, "SpaceX", "Should load correct company name")
        XCTAssertEqual(sut.company?.founder, "Elon Musk", "Should load founder")
        XCTAssertGreaterThan(sut.company?.employees ?? 0, 0, "Should have employee count")
        XCTAssertGreaterThan(sut.company?.valuation ?? 0, 0, "Should have valuation")
    }
    
    func testErrorHandling() async {
        // Given
        mockCompanyRepo.shouldThrowError = true
        
        // When
        await sut.loadCompany()
        
        XCTAssertNil(sut.company, "Should have no company data")
        XCTAssertFalse(sut.isLoading, "Should stop loading")
        XCTAssertNotNil(sut.errorMessage, "Should show error message")
    }
    
    func testForceRefresh() async {
        // Given
        await sut.loadCompany()
        XCTAssertNotNil(sut.company, "Should have initial data")
        
        // When
        await sut.loadCompany(forceRefresh: true)
        
        // Then
        XCTAssertNotNil(sut.company, "Should maintain company data")
        XCTAssertFalse(sut.isLoading, "Should finish refreshing")
        XCTAssertNil(sut.errorMessage, "Should clear any errors")
    }
    
    // MARK: - State Management
    
    func testLoadingStates() async {
        // Given
        mockCompanyRepo.delay = 0.1
        
        // When
        let loadTask = Task {
            await sut.loadCompany()
        }
        
        // Then
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        XCTAssertTrue(sut.isLoading, "Should be loading")
        
        await loadTask.value
        XCTAssertFalse(sut.isLoading, "Should finish loading")
    }
    
    func testConcurrentLoadProtection() async {
        // Given
        mockCompanyRepo.delay = 0.2
        
        // When
        async let load1: Void = sut.loadCompany()
        async let load2: Void = sut.loadCompany()
        async let load3: Void = sut.loadCompany()
        
        _ = await (load1, load2, load3)
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should not be stuck loading")
    }
    
    func testTaskCancellationOnForceRefresh() async {
        // Given
        mockCompanyRepo.delay = 0.3
        
        Task {
            await sut.loadCompany()
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        XCTAssertTrue(sut.isLoading, "Should be loading")
        
        // When
        await sut.loadCompany(forceRefresh: true)
        
        // Then
        XCTAssertNotNil(sut.company, "Should have company data")
        XCTAssertFalse(sut.isLoading, "Should finish loading")
    }
}
