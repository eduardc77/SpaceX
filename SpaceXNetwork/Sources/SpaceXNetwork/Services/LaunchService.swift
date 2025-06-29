//
//  LaunchService.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols
import SpaceXUtilities

public final class LaunchService: LaunchServiceProtocol {
    private let client: APIClient
    private let environment: APIEnvironment
    
    public init(
        client: APIClient = SpaceXAPIClient(),
        environment: APIEnvironment = SpaceXEnvironment.current
    ) {
        self.client = client
        self.environment = environment
    }
    
    public func fetchAllLaunches() async throws -> [Launch] {
        let dtos: [LaunchDTO] = try await client.request(LaunchEndpoint.allLaunches, in: environment)
        return dtos.map { $0.toDomain() }
    }
    
    public func fetchLaunch(id: String) async throws -> Launch {
        let dto: LaunchDTO = try await client.request(LaunchEndpoint.launch(id: id), in: environment)
        return dto.toDomain()
    }
    
    public func fetchLaunches(query: LaunchQuery) async throws -> PaginatedLaunches {
        let response: PaginatedLaunchDTO = try await client.request(LaunchEndpoint.query(query), in: environment)
        return response.toDomain()
    }
    
    public func fetchUpcomingLaunches() async throws -> [Launch] {
        let dtos: [LaunchDTO] = try await client.request(LaunchEndpoint.upcomingLaunches, in: environment)
        return dtos.map { $0.toDomain() }
    }
    
    public func fetchPastLaunches() async throws -> [Launch] {
        let dtos: [LaunchDTO] = try await client.request(LaunchEndpoint.pastLaunches, in: environment)
        return dtos.map { $0.toDomain() }
    }
    
    public func fetchAvailableYears() async throws -> Set<Int> {
        // The API returns a paginated response even with select fields
        struct PaginatedDateResponse: Codable {
            let docs: [LaunchDateOnlyDTO]
        }
        
        // Use the dedicated endpoint that encapsulates the query details
        let response: PaginatedDateResponse = try await client.request(
            LaunchEndpoint.availableYears,
            in: environment
        )
        
        // Convert string dates to Date objects using the API date formatter
        let dates = response.docs.compactMap { dto -> Date? in
            return dto.dateUtc.toSpaceXDate()
        }
        
        let years = dates.uniqueYears
        SpaceXLogger.network("📅 Parsed \(dates.count) dates from \(response.docs.count) launches, found \(years.count) unique years")
        
        return years
    }
}
