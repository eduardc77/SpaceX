//
//  CompanyDataSourceProtocol.swift
//  SpaceXProtocols
//
//  Created by User on 6/25/25.
//

import SpaceXDomain

public protocol CompanyDataSourceProtocol {
    func saveCompany(_ company: Company) async throws
    func fetchCompany() async throws -> Company?
    func clearCompany() async throws
}
