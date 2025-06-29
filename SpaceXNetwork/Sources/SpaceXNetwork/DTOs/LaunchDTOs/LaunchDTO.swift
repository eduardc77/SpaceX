//
//  LaunchDTO.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import SpaceXDomain

struct LaunchDTO: Codable, Sendable {
    let id: String
    let name: String
    let details: String?
    let upcoming: Bool
    let success: Bool?
    let dateUtc: String
    let dateUnix: Int
    let links: LaunchLinksDTO
    let rocket: String
    let flightNumber: Int
    let cores: [LaunchCoreDTO]
    
    func toDomain() -> Launch {
        Launch(
            id: id,
            name: name,
            details: details,
            upcoming: upcoming,
            success: success,
            dateUtc: dateUtc,
            dateUnix: dateUnix,
            links: links.toDomain(),
            rocket: rocket,
            flightNumber: flightNumber,
            cores: cores.map { $0.toDomain() }
        )
    }
}

struct PaginatedLaunchDTO: Codable, Sendable {
    let docs: [LaunchDTO]
    let totalDocs: Int
    let limit: Int
    let page: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPrevPage: Bool
    let nextPage: Int?
    let prevPage: Int?
    
    func toDomain() -> PaginatedLaunches {
        PaginatedLaunches(
            launches: docs.map { $0.toDomain() },
            totalCount: totalDocs,
            currentPage: page,
            totalPages: totalPages,
            hasNextPage: hasNextPage,
            hasPrevPage: hasPrevPage,
            pageSize: limit
        )
    }
}
