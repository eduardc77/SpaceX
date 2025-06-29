//
//  LaunchServiceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol LaunchServiceProtocol: Sendable {
    func fetchAllLaunches() async throws -> [Launch]
    func fetchLaunch(id: String) async throws -> Launch
    func fetchLaunches(query: LaunchQuery) async throws -> PaginatedLaunches
    func fetchUpcomingLaunches() async throws -> [Launch]
    func fetchPastLaunches() async throws -> [Launch]
    func fetchAvailableYears() async throws -> Set<Int>
}
