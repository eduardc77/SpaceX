//
//  MockCompanyRepository.swift
//  SpaceXMocks
//
//  Created by User on 6/24/25.
//

import Foundation
import SpaceXDomain

public class MockCompanyRepository: CompanyRepositoryProtocol {
    public var shouldThrowError = false
    public var delay: TimeInterval = 0.4
    
    public init() {}
    
    public func getCompany(forceRefresh: Bool) async throws -> Company? {
        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }
        
        return Company(
            name: "SpaceX",
            founder: "Elon Musk",
            founded: 2002,
            employees: 8000,
            ceo: "Elon Musk",
            valuation: 27500000000,
            headquarters: Headquarters(
                address: "Rocket Road", 
                city: "Hawthorne", 
                state: "CA"
            ),
            links: CompanyLinks(
                website: "https://www.spacex.com",
                twitter: "https://twitter.com/SpaceX"
            ),
            summary: "SpaceX designs, manufactures and launches advanced rockets and spacecraft."
        )
    }
}
