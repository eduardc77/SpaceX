//
//  CompanyEndpoint.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

enum CompanyEndpoint: APIEndpoint {
    case companyInfo
    
    public var path: String {
        switch self {
        case .companyInfo:
            return "/company"
        }
    }
    
    var httpMethod: HTTPMethod { .get }
    var apiVersion: APIVersion? { .v4 }
}
