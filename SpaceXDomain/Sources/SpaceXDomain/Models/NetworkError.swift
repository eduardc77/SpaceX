//
//  NetworkError.swift
//  SpaceXDomain
//
//  Created by User on 6/21/25.
//

public enum NetworkError: Error, Sendable {
    case invalidURL
    case noData
    case decodingError(String)
    case httpError(Int)
    case networkError(Error)
} 
