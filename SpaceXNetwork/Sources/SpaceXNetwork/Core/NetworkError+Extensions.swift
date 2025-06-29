//
//  NetworkError+Extensions.swift
//  SpaceXNetwork
//
//  Created by User on 6/26/25.
//

import Foundation
import SpaceXDomain

public extension NetworkError {
    
    var isCertificatePinningFailure: Bool {
        // Only treat SSL errors as pinning failures in production
        // In development, SSL errors are expected (proxies, etc.)
        guard SpaceXEnvironment.current != .development else {
            return false
        }
        
        // Check if this is actually a certificate-related error
        switch self {
        case .networkError(let error):
            // Check if it's a URLError
            if let urlError = error as? URLError {
                switch urlError.code {
                case .cancelled,
                        .secureConnectionFailed,
                        .serverCertificateHasBadDate,
                        .serverCertificateUntrusted,
                        .serverCertificateNotYetValid:
                    return true
                default:
                    return false
                }
            }
            
            // Fallback to NSError checking
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain &&
                (nsError.code == NSURLErrorCancelled ||
                 nsError.code == NSURLErrorServerCertificateUntrusted ||
                 nsError.code == NSURLErrorServerCertificateHasBadDate ||
                 nsError.code == NSURLErrorServerCertificateNotYetValid ||
                 nsError.code == NSURLErrorSecureConnectionFailed) {
                return true
            }
            
            return false
        default:
            return false
        }
    }
    
    var errorMessage: String {
        if isCertificatePinningFailure {
            return "Unable to establish a secure connection. Please check your network settings."
        }
        
        switch self {
        case .networkError:
            return "Network connection failed. Please check your internet connection."
        case .httpError(let code):
            return "Server error (Code: \(code))"
        case .decodingError:
            return "Unable to process server response"
        case .invalidURL:
            return "Invalid request"
        case .noData:
            return "No data received"
        }
    }
}
