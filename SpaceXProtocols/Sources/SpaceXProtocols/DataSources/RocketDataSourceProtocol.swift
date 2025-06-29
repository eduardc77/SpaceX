//
//  RocketDataSourceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol RocketDataSourceProtocol {
    func saveRockets(_ rockets: [Rocket]) async throws
    func fetchAllRockets() async throws -> [Rocket]
    func fetchRocket(by id: String) async throws -> Rocket?
    func deleteRocket(by id: String) async throws
    func clearAllRockets() async throws
}
