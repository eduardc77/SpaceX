//
//  LaunchDataSourceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol LaunchDataSourceProtocol {
    func saveLaunches(_ launches: [Launch]) async throws
    func fetchAllLaunches() async throws -> [Launch]
    func fetchLaunches(page: Int, pageSize: Int, sortOption: LaunchSortOption, filter: LaunchFilter) async throws -> [Launch]
    func fetchLaunch(by id: String) async throws -> Launch?
    func deleteLaunch(by id: String) async throws
    func clearAllLaunches() async throws
    func getLaunchCount(filter: LaunchFilter) async throws -> Int
    func saveCachedYears(_ years: [Int]) async throws
    func fetchCachedYears() async throws -> [Int]?
}
