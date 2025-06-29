//
//  MockCompanyService.swift
//  SpaceXMocks
//
//  Created by User on 6/25/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public final class MockCompanyService: CompanyServiceProtocol, @unchecked Sendable {
    public var mockCompany: Company?
    public var shouldThrowError = false
    public var error: Error = NetworkError.networkError(URLError(.networkConnectionLost))
    public var callCount = 0

    public init() {}

    public func fetchCompanyInfo(bypassCache: Bool) async throws -> Company {
        callCount += 1
        if shouldThrowError { throw error }
        guard let company = mockCompany else {
            throw NetworkError.httpError(500)
        }
        return company
    }
} 
