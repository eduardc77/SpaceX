//
//  CompanyEntity.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import Foundation
import SpaceXDomain

@Model
final class CompanyEntity {
    @Attribute(.unique) var id: String
    var name: String
    var founder: String
    var founded: Int
    var employees: Int
    var ceo: String
    var valuation: Int64
    var summary: String

    @Relationship(deleteRule: .cascade, inverse: \HeadquartersEntity.company)
    var headquarters: HeadquartersEntity?

    @Relationship(deleteRule: .cascade, inverse: \CompanyLinksEntity.company)
    var links: CompanyLinksEntity?

    init(
        id: String = "spacex",
        name: String,
        founder: String,
        founded: Int,
        employees: Int,
        ceo: String,
        valuation: Int64,
        summary: String,
        headquarters: HeadquartersEntity? = nil,
        links: CompanyLinksEntity? = nil
    ) {
        self.id = id
        self.name = name
        self.founder = founder
        self.founded = founded
        self.employees = employees
        self.ceo = ceo
        self.valuation = valuation
        self.summary = summary
        self.headquarters = headquarters
        self.links = links
    }
}

// MARK: - Domain Mapping

extension CompanyEntity {
    /// Convert SwiftData entity to Domain model
    func toDomain() -> Company {
        let headquarters = self.headquarters?.toDomain() ?? Headquarters(address: "", city: "", state: "")
        let links = self.links?.toDomain() ?? CompanyLinks(website: "", twitter: "")

        return Company(
            name: name,
            founder: founder,
            founded: founded,
            employees: employees,
            ceo: ceo,
            valuation: valuation,
            headquarters: headquarters,
            links: links,
            summary: summary
        )
    }

    /// Create SwiftData entity from Domain model
    static func fromDomain(_ company: Company) -> CompanyEntity {
        let entity = CompanyEntity(
            name: company.name,
            founder: company.founder,
            founded: company.founded,
            employees: company.employees,
            ceo: company.ceo,
            valuation: company.valuation,
            summary: company.summary
        )

        let headquartersEntity = HeadquartersEntity.fromDomain(company.headquarters)
        let linksEntity = CompanyLinksEntity.fromDomain(company.links)

        entity.headquarters = headquartersEntity
        entity.links = linksEntity
        headquartersEntity.company = entity
        linksEntity.company = entity

        return entity
    }
}
