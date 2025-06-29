//
//  APIEnvironment.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import Foundation

public protocol APIEnvironment: Sendable {
    var scheme: String { get }
    var host: String { get }
}

extension APIEnvironment {
    // Default value
    public var scheme: String { "https" }
}

public enum SpaceXEnvironment: APIEnvironment {
    case development
    case staging
    case production
    
    public var scheme: String { "https" }
    public var host: String { "api.spacexdata.com" }
}

public extension SpaceXEnvironment {
    static var current: SpaceXEnvironment {
        guard let environmentString = Bundle.main.object(forInfoDictionaryKey: "API_ENVIRONMENT") as? String else {
            return .production
        }
        
        switch environmentString.lowercased() {
        case "development", "debug":
            return .development
        case "staging":
            return .staging
        case "production", "release":
            return .production
        default:
            return .production
        }
    }
}
