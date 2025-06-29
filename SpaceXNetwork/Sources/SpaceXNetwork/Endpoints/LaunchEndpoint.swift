//
//  LaunchEndpoint.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain

enum LaunchEndpoint: APIEndpoint {
    case allLaunches
    case launch(id: String)
    case query(LaunchQuery)
    case upcomingLaunches
    case pastLaunches
    case availableYears
    
    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    var path: String {
        switch self {
        case .allLaunches:
            return "/launches"
        case .launch(let id):
            return "/launches/\(id)"
        case .query, .availableYears:
            return "/launches/query"
        case .upcomingLaunches:
            return "/launches/upcoming"
        case .pastLaunches:
            return "/launches/past"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .allLaunches, .launch, .upcomingLaunches, .pastLaunches:
            return .get
        case .query, .availableYears:
            return .post
        }
    }
    
    var body: Data? {
        switch self {
        case .allLaunches, .launch, .upcomingLaunches, .pastLaunches:
            return nil
            
        case .query(let launchQuery):
            return try? LaunchEndpoint.encoder.encode(launchQuery)
            
        case .availableYears:
            let query = LaunchQuery(
                query: nil,
                options: QueryOptions(
                    limit: 2000,
                    page: 1,
                    sort: ["date_utc": "desc"],
                    select: ["date_utc": 1]  // Only fetch the date field for efficiency
                )
            )
            return try? LaunchEndpoint.encoder.encode(query)
        }
    }
    
    public var apiVersion: APIVersion? { .v5 }
}
