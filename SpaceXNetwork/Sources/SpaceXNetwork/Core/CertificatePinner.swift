//
//  CertificatePinner.swift
//  SpaceXNetwork
//
//  Created by User on 6/26/25.
//

import Foundation
import Security
import CryptoKit
import SpaceXUtilities

public final class CertificatePinner: Sendable {

    private let pinnedCertificateHashes: Set<String>
    private let allowSelfSignedCertificates: Bool
    private let validateCertificateChain: Bool

    public init(
        pinnedCertificateHashes: [String],
        allowSelfSignedCertificates: Bool = false,
        validateCertificateChain: Bool = true
    ) {
        self.pinnedCertificateHashes = Set(pinnedCertificateHashes)
        self.allowSelfSignedCertificates = allowSelfSignedCertificates
        self.validateCertificateChain = validateCertificateChain
    }
    
    /// Validates the server trust against pinned certificate hashes
    public func validateServerTrust(_ serverTrust: SecTrust) -> Bool {
        SpaceXLogger.network("🔒 Starting certificate hash validation")
        SpaceXLogger.network("   Pinned certificate hashes count: \(pinnedCertificateHashes.count)")

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

        // Validate certificates against hashes
        for (index, certificate) in certificatesToValidate.enumerated() {
            if let certificateHash = calculateCertificateHash(certificate) {
                SpaceXLogger.network("   Checking certificate #\(index + 1) hash: \(certificateHash.prefix(16))...")
                if pinnedCertificateHashes.contains(certificateHash) {
                    SpaceXLogger.network("✅ Found matching pinned certificate hash at index \(index)")
                    return true
                }
            } else {
                SpaceXLogger.error("❌ Failed to calculate hash for certificate #\(index + 1)")
            }
        }

        SpaceXLogger.error("❌ No matching certificate hash found in pinned hashes")
        return false
    }
    
    /// Calculates SHA-256 hash of the certificate data
    private func calculateCertificateHash(_ certificate: SecCertificate) -> String? {
        let certificateData = SecCertificateCopyData(certificate) as Data
        let hash = SHA256.hash(data: certificateData)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
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

    /// Creates a certificate pinner for SpaceX API using SHA-256 certificate hashes
    /// Note: Update these hashes with the actual SHA-256 hashes of the SpaceX API certificates
    static func spaceXAPIPinner() -> CertificatePinner {
        // TODO: Replace with actual SHA-256 certificate hashes from SpaceX API certificates
        // You can obtain these by:
        // 1. Connect to https://api.spacexdata.com/v4/launches
        // 2. Extract the certificate chain using browser dev tools or openssl
        // 3. Calculate SHA-256 hash of each certificate
        // 4. Add the hashes here
        let certificateHashes: [String] = [
            // SHA-256 hash of SpaceX API certificate (api.spacexdata.com)
            "8ebfd584b67f63646f874ab3021ae954ffc1d6fd4fbac45ca8ed783994abac06"
        ]

        SpaceXLogger.network("🔒 Certificate Pinning: Using hash-based pinning with \(certificateHashes.count) certificate hash(es)")

        return CertificatePinner(
            pinnedCertificateHashes: certificateHashes,
            allowSelfSignedCertificates: false,
            validateCertificateChain: true
        )
    }
} 
