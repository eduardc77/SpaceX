//
//  CompanyRepositoryProtocol.swift
//  SpaceXDomain
//
//  Created by User on 6/22/25.
//

public protocol CompanyRepositoryProtocol {
    func getCompany(forceRefresh: Bool) async throws -> Company?
}
