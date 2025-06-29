//
//  CertificatePinner.swift
//  SpaceXNetwork
//
//  Created by User on 6/26/25.
//

import Foundation
import Security
import SpaceXUtilities

public final class CertificatePinner: Sendable {
    
    private let pinnedCertificates: Set<Data>
    private let allowSelfSignedCertificates: Bool
    private let validateCertificateChain: Bool
    
    public init(
        pinnedCertificates: [Data],
        allowSelfSignedCertificates: Bool = false,
        validateCertificateChain: Bool = true
    ) {
        self.pinnedCertificates = Set(pinnedCertificates)
        self.allowSelfSignedCertificates = allowSelfSignedCertificates
        self.validateCertificateChain = validateCertificateChain
    }
    
    /// Validates the server trust against pinned certificates
    public func validateServerTrust(_ serverTrust: SecTrust) -> Bool {
        SpaceXLogger.network("🔒 Starting certificate validation")
        SpaceXLogger.network("   Pinned certificates count: \(pinnedCertificates.count)")
        
        let policy = SecPolicyCreateSSL(true, "api.spacexdata.com" as CFString)
        SecTrustSetPolicies(serverTrust, policy)
        
        // Evaluate the trust
        var error: CFError?
        let isValid = SecTrustEvaluateWithError(serverTrust, &error)
        
        if !isValid && !allowSelfSignedCertificates {
            SpaceXLogger.error("❌ Server trust evaluation failed: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        // Get certificate chain
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] else {
            SpaceXLogger.error("❌ Failed to get certificate chain")
            return false
        }
        
        SpaceXLogger.network("   Certificate chain count: \(certificateChain.count)")
        
        // Check if we should validate the entire chain or just the leaf certificate
        let certificatesToValidate = validateCertificateChain ? certificateChain : [certificateChain[0]]
        
        SpaceXLogger.network("   Validating \(certificatesToValidate.count) certificate(s)")
        
        // Validate certificates
        for (index, certificate) in certificatesToValidate.enumerated() {
            let certificateData = SecCertificateCopyData(certificate) as Data
            SpaceXLogger.network("   Checking certificate #\(index + 1) (\(certificateData.count) bytes)")
            if pinnedCertificates.contains(certificateData) {
                SpaceXLogger.network("✅ Found matching pinned certificate at index \(index)")
                return true
            }
        }
        
        SpaceXLogger.error("❌ No matching certificate found in pinned certificates")
        return false
    }
    
    /// Extracts the public key from a certificate for public key pinning
    public func extractPublicKey(from certificate: SecCertificate) -> Data? {
        guard let publicKey = SecCertificateCopyKey(certificate) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        guard let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            return nil
        }
        
        return publicKeyData
    }
}

// MARK: - Helpers

public extension CertificatePinner {
    
    /// Loads certificates from the app bundle
    static func loadCertificates(named names: [String]) -> [Data] {
        return names.compactMap { name in
            guard let url = Bundle.main.url(forResource: name, withExtension: "cer"),
                  let data = try? Data(contentsOf: url) else {
                SpaceXLogger.error("❌ Failed to load certificate: \(name).cer from bundle")
                return nil
            }
            SpaceXLogger.network("✅ Successfully loaded certificate: \(name).cer (\(data.count) bytes)")
            return data
        }
    }
    
    /// Creates a certificate pinner for SpaceX API
    static func spaceXAPIPinner() -> CertificatePinner {
        let certificates = loadCertificates(named: ["spacexdata"])
        
        return CertificatePinner(
            pinnedCertificates: certificates,
            allowSelfSignedCertificates: false,
            validateCertificateChain: true
        )
    }
} 
