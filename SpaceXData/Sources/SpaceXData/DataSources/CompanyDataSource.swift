//
//  CompanyDataSource.swift
//  SpaceXData
//
//  Created by User on 6/21/25.
//

import SwiftData
import Foundation
import SpaceXDomain
import SpaceXProtocols

/// SwiftData implementation of CompanyDataSource
@MainActor
final class CompanyDataSource: CompanyDataSourceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func saveCompany(_ company: Company) async throws {
        try await clearCompany()
        let entity = CompanyEntity.fromDomain(company)
        modelContext.insert(entity)
        try modelContext.save()
    }
    
    func fetchCompany() async throws -> Company? {
        let descriptor = FetchDescriptor<CompanyEntity>()
        let entities = try modelContext.fetch(descriptor)
        return entities.first?.toDomain()
    }
    
    func clearCompany() async throws {
        try modelContext.delete(model: CompanyEntity.self)
        try modelContext.save()
    }
}
