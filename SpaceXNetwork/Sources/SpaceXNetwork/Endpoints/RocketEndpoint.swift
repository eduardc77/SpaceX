//
//  RocketEndpoint.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

enum RocketEndpoint: APIEndpoint {
    case allRockets
    case rocket(id: String)
    
    public var path: String {
        switch self {
        case .allRockets:
            return "/rockets"
        case .rocket(let id):
            return "/rockets/\(id)"
        }
    }
    
    var httpMethod: HTTPMethod { .get }
    var apiVersion: APIVersion? { .v4 }
}
