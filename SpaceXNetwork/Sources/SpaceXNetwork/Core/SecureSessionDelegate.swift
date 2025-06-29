//
//  SecureSessionDelegate.swift
//  SpaceXNetwork
//
//  Created by User on 6/26/25.
//

import Foundation
import SpaceXUtilities

/// URLSession delegate that implements certificate pinning
public final class SecureSessionDelegate: NSObject {
    
    // MARK: - Properties
    
    private let certificatePinner: CertificatePinner
    
    // MARK: - Initialization
    
    public init(certificatePinner: CertificatePinner) {
        self.certificatePinner = certificatePinner
        super.init()
    }
}

// MARK: - URLSessionDelegate

extension SecureSessionDelegate: URLSessionDelegate {
    
    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Only handle server trust challenges
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            // For other types of challenges, use default handling
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        // Validate the host
        let host = challenge.protectionSpace.host
        guard host == "api.spacexdata.com" else {
            SpaceXLogger.error("🔒 Certificate Pinning: Unexpected host: \(host)")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        SpaceXLogger.network("🔒 Certificate Pinning: Validating certificate for \(host)")
        
        // Perform certificate validation synchronously
        let isValid = certificatePinner.validateServerTrust(serverTrust)
        
        if isValid {
            SpaceXLogger.network("✅ Certificate Pinning: Certificate validated successfully for \(host)")
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            SpaceXLogger.error("❌ Certificate Pinning: Certificate validation failed for \(host)")
            SpaceXLogger.error("   This will result in NSURLErrorCancelled (-999)")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// MARK: - URLSessionTaskDelegate

extension SecureSessionDelegate: URLSessionTaskDelegate {
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        if let error = error {
            SpaceXLogger.error("🔒 Secure session task failed: \(error.localizedDescription)")
        }
    }
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        // Forward to the session-level handler
        urlSession(session, didReceive: challenge, completionHandler: completionHandler)
    }
}
