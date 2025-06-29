//
//  RocketRepositoryProtocol.swift
//  SpaceXDomain
//
//  Created by User on 6/21/25.
//

import Foundation

public protocol RocketRepositoryProtocol {
    func getAllRocketNames(forceRefresh: Bool) async throws -> [String: String]
    func getRocketNames(for rocketIds: [String]) async throws -> [String: String]
    func getRocket(id: String) async throws -> Rocket?
} 
