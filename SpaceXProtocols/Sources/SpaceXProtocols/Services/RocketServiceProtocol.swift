//
//  RocketServiceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol RocketServiceProtocol: Sendable {
    func fetchAllRockets() async throws -> [Rocket]
    func fetchRocket(id: String) async throws -> Rocket
}
