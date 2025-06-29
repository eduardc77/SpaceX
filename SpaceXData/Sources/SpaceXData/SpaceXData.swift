//
//  SpaceXData.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import Foundation
import SpaceXDomain
import SpaceXNetwork
import SpaceXUtilities

// MARK: - Model Container Factory

public func createSpaceXModelContainer() throws -> ModelContainer {
    let schema = Schema([
        LaunchEntity.self,
        LaunchLinksEntity.self,
        LaunchPatchEntity.self,

        LaunchCoreEntity.self,
        LaunchYearEntity.self,
        RocketEntity.self,
        CompanyEntity.self,
        HeadquartersEntity.self,
        CompanyLinksEntity.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )

    return try ModelContainer(
        for: schema,
        configurations: [configuration]
    )
}

// MARK: - Repository Factory

@MainActor
public func createSpaceXRepositories(
    modelContext: ModelContext,
    networkMonitor: NetworkMonitor? = nil
) -> SpaceXRepositories {
    let launchDataSource = LaunchDataSource(modelContext: modelContext)
    let rocketDataSource = RocketDataSource(modelContext: modelContext)
    let companyDataSource = CompanyDataSource(modelContext: modelContext)

    // Create ONE API client for all services with network monitoring
    let apiClient = SpaceXAPIClient(
        configuration: .current,
        decoder: nil,
        session: nil,
        networkMonitor: networkMonitor
    )

    let launchNetworkService = LaunchService(client: apiClient)
    let rocketNetworkService = RocketService(client: apiClient)
    let companyNetworkService = CompanyService(client: apiClient)

    let launchRepository = LaunchRepository(
        launchService: launchNetworkService,
        localDataSource: launchDataSource
    )

    let rocketRepository = RocketRepository(
        networkService: rocketNetworkService,
        localDataSource: rocketDataSource
    )

    let companyRepository = CompanyRepository(
        networkService: companyNetworkService,
        localDataSource: companyDataSource
    )

    return SpaceXRepositories(
        launchRepository: launchRepository,
        rocketRepository: rocketRepository,
        companyRepository: companyRepository
    )
}
