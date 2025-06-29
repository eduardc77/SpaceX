//
//  LaunchRepositoryProtocol.swift
//  SpaceXDomain
//
//  Created by User on 6/21/25.
//

import Foundation

public protocol LaunchRepositoryProtocol {
    func getLaunches(
        page: Int, 
        pageSize: Int, 
        sortOption: LaunchSortOption, 
        filter: LaunchFilter, 
        forceRefresh: Bool
    ) async throws -> PaginatedLaunches
    func getAvailableYears() async throws -> [Int]
} 
