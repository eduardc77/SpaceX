//
//  CompanyService.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain
import SpaceXProtocols

public final class CompanyService: CompanyServiceProtocol {
    private let client: APIClient
    private let environment: APIEnvironment
    
    public init(
        client: APIClient = SpaceXAPIClient(),
        environment: APIEnvironment = SpaceXEnvironment.production
    ) {
        self.client = client
        self.environment = environment
    }
    
    public func fetchCompanyInfo(bypassCache: Bool = false) async throws -> Company {
        let dto: CompanyDTO = try await client.request(CompanyEndpoint.companyInfo, in: environment, bypassCache: bypassCache)
        return dto.toDomain()
    }
}
