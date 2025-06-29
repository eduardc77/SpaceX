//
//  CompanyServiceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol CompanyServiceProtocol: Sendable {
    func fetchCompanyInfo(bypassCache: Bool) async throws -> Company
}
