//
//  APIEndpoint.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain

public protocol APIEndpoint: Sendable {
    var httpMethod: HTTPMethod { get }
    var path: String { get }
    var queryParams: [String: String]? { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var apiVersion: APIVersion? { get }
}

extension APIEndpoint {
    public var headers: [String: String]? { nil }
    public var queryParams: [String: String]? { nil }
    public var body: Data? { nil }
    
    public func urlRequest(for environment: APIEnvironment) throws -> URLRequest {
        let urlComponents = makeURLComponents(from: environment)
        guard let requestURL = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = httpMethod.rawValue
        urlRequest.timeoutInterval = 30.0
        
        // Set headers
        var allHeaders = headers ?? [:]
        if body != nil {
            allHeaders["Content-Type"] = "application/json"
        }
        urlRequest.allHTTPHeaderFields = allHeaders
        
        // Set body for POST requests
        urlRequest.httpBody = body
        
        return urlRequest
    }
    
    private func makeURLComponents(from environment: APIEnvironment) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = environment.scheme
        urlComponents.host = environment.host
        urlComponents.path = pathComponent(for: environment)
        
        if let queryParams = queryParams, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map {
                URLQueryItem(name: $0.key, value: $0.value)
            }
        }
        
        return urlComponents
    }
    
    private func pathComponent(for environment: APIEnvironment) -> String {
        var pathComponent = ""
        if let apiVersion = apiVersion?.rawValue {
            pathComponent += apiVersion
        }
        pathComponent += path
        return pathComponent
    }
}

// MARK: - Supporting Types

public enum APIVersion: String, Sendable {
    case v4 = "/v4"
    case v5 = "/v5"
}
