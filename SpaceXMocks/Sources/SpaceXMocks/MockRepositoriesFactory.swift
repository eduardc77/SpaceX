//
//  MockRepositoriesFactory.swift
//  SpaceXMocks
//
//  Created by User on 6/24/25.
//

import Foundation
import SpaceXDomain
import SpaceXProtocols

public struct MockRepositoriesFactory {
    public let launchRepository: LaunchRepositoryProtocol
    public let rocketRepository: RocketRepositoryProtocol
    public let companyRepository: CompanyRepositoryProtocol
    
    public init(
        launchRepository: LaunchRepositoryProtocol = MockLaunchRepository(),
        rocketRepository: RocketRepositoryProtocol = MockRocketRepository(),
        companyRepository: CompanyRepositoryProtocol = MockCompanyRepository()
    ) {
        self.launchRepository = launchRepository
        self.rocketRepository = rocketRepository
        self.companyRepository = companyRepository
    }
    
    // Convenience factory methods
    public static func `default`() -> MockRepositoriesFactory {
        MockRepositoriesFactory()
    }
    
    public static func withErrors() -> MockRepositoriesFactory {
        let launchRepo = MockLaunchRepository()
        launchRepo.shouldThrowError = true
        
        let rocketRepo = MockRocketRepository()
        rocketRepo.shouldThrowError = true
        
        let companyRepo = MockCompanyRepository()
        companyRepo.shouldThrowError = true
        
        return MockRepositoriesFactory(
            launchRepository: launchRepo,
            rocketRepository: rocketRepo,
            companyRepository: companyRepo
        )
    }
    
    public static func fast() -> MockRepositoriesFactory {
        let launchRepo = MockLaunchRepository()
        launchRepo.delay = 0.1
        
        let rocketRepo = MockRocketRepository()
        rocketRepo.delay = 0.1
        
        let companyRepo = MockCompanyRepository()
        companyRepo.delay = 0.1
        
        return MockRepositoriesFactory(
            launchRepository: launchRepo,
            rocketRepository: rocketRepo,
            companyRepository: companyRepo
        )
    }
    
    public static func instant() -> MockRepositoriesFactory {
        let launchRepo = MockLaunchRepository()
        launchRepo.delay = 0.0
        launchRepo.yearsFetchDelay = 0.0
        
        let rocketRepo = MockRocketRepository()
        rocketRepo.delay = 0.0
        
        let companyRepo = MockCompanyRepository()
        companyRepo.delay = 0.0
        
        return MockRepositoriesFactory(
            launchRepository: launchRepo,
            rocketRepository: rocketRepo,
            companyRepository: companyRepo
        )
    }
}

// MARK: - SpaceXRepositories Factory

@MainActor
public func createMockRepositories() -> SpaceXRepositories {
    let mockFactory = MockRepositoriesFactory.instant()
    return SpaceXRepositories(
        launchRepository: mockFactory.launchRepository,
        rocketRepository: mockFactory.rocketRepository,
        companyRepository: mockFactory.companyRepository
    )
}
