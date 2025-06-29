//
//  MockCompanyDataSource.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public class MockCompanyDataSource: CompanyDataSourceProtocol {
    public var mockCompany: Company?
    public var shouldThrowError = false
    public var error: Error = NSError(domain: "Test", code: 1, userInfo: nil)

    public var saveCallCount = 0
    public var fetchCallCount = 0
    public var clearCallCount = 0

    public init() {}

    public func saveCompany(_ company: Company) async throws {
        saveCallCount += 1
        if shouldThrowError { throw error }
        mockCompany = company
    }

    public func fetchCompany() async throws -> Company? {
        fetchCallCount += 1
        if shouldThrowError { throw error }
        return mockCompany
    }

    public func clearCompany() async throws {
        clearCallCount += 1
        if shouldThrowError { throw error }
        mockCompany = nil
    }
}
