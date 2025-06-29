//
//  RocketService.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain
import SpaceXProtocols

public final class RocketService: RocketServiceProtocol {
    private let client: APIClient
    private let environment: APIEnvironment
    
    public init(
        client: APIClient = SpaceXAPIClient(),
        environment: APIEnvironment = SpaceXEnvironment.production
    ) {
        self.client = client
        self.environment = environment
    }
    
    public func fetchAllRockets() async throws -> [Rocket] {
        let dtos: [RocketDTO] = try await client.request(RocketEndpoint.allRockets, in: environment)
        return dtos.map { $0.toDomain() }
    }
    
    public func fetchRocket(id: String) async throws -> Rocket {
        let dto: RocketDTO = try await client.request(RocketEndpoint.rocket(id: id), in: environment)
        return dto.toDomain()
    }
}
