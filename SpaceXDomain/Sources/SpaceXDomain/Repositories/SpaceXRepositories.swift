//
//  SpaceXRepositories.swift
//  SpaceXDomain
//
//  Created by User on 6/25/25.
//

import Observation

@Observable public class SpaceXRepositories {
    public let launchRepository: LaunchRepositoryProtocol
    public let rocketRepository: RocketRepositoryProtocol
    public let companyRepository: CompanyRepositoryProtocol
    
    public init(
        launchRepository: LaunchRepositoryProtocol,
        rocketRepository: RocketRepositoryProtocol,
        companyRepository: CompanyRepositoryProtocol
    ) {
        self.launchRepository = launchRepository
        self.rocketRepository = rocketRepository
        self.companyRepository = companyRepository
    }
}
