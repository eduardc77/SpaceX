//
//  Company.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

import Foundation
import SpaceXUtilities

public struct Company: Codable, Sendable {
    public let name: String
    public let founder: String
    public let founded: Int
    public let employees: Int
    public let ceo: String
    public let valuation: Int64
    public let headquarters: Headquarters
    public let links: CompanyLinks
    public let summary: String
    
    public init(
        name: String,
        founder: String,
        founded: Int,
        employees: Int,
        ceo: String,
        valuation: Int64,
        headquarters: Headquarters,
        links: CompanyLinks,
        summary: String
    ) {
        self.name = name
        self.founder = founder
        self.founded = founded
        self.employees = employees
        self.ceo = ceo
        self.valuation = valuation
        self.headquarters = headquarters
        self.links = links
        self.summary = summary
    }
}

public extension Company {
    
    var formattedDescription: String {
        let employeeCount = NumberFormatter.decimal(employees)
        let valuationText = NumberFormatter.abbreviated(valuation)
        
        return "\(name) was founded by \(founder) in \(founded). It has now \(employeeCount) employees, \(headquarters.state) launch sites, and is valued at USD \(valuationText)"
    }
}
