//
//  APIClient.swift
//  SpaceXNetwork
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain
import SpaceXUtilities

public protocol APIClient: Sendable {
    func request<T: Decodable & Sendable>(_ route: APIEndpoint, in environment: APIEnvironment, bypassCache: Bool) async throws -> T
}

// MARK: - Default
public extension APIClient {
    func request<T: Decodable & Sendable>(_ route: APIEndpoint, in environment: APIEnvironment) async throws -> T {
        return try await request(route, in: environment, bypassCache: false)
    }
}

public final class SpaceXAPIClient: APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let certificatePinner: CertificatePinner?
    private let sessionDelegate: SecureSessionDelegate?
    private let networkMonitor: NetworkMonitoring?
    
    private static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    public struct Configuration: Sendable {
        public let enableCertificatePinning: Bool
        public let timeoutInterval: TimeInterval
        
        public init(
            enableCertificatePinning: Bool = true,
            timeoutInterval: TimeInterval = 30.0
        ) {
            self.enableCertificatePinning = enableCertificatePinning
            self.timeoutInterval = timeoutInterval
        }
        
        public static let production = Configuration(enableCertificatePinning: true)
        public static let development = Configuration(enableCertificatePinning: false)
        
        // Create configuration based on current environment
        public static var current: Configuration {
            switch SpaceXEnvironment.current {
            case .production:
                return .production
            case .development, .staging:
                return .development
            }
        }
    }
    
    public init(
        configuration: Configuration = .current,
        decoder: JSONDecoder? = nil,
        session: URLSession? = nil,
        networkMonitor: NetworkMonitoring? = nil
    ) {
        self.decoder = decoder ?? Self.defaultDecoder
        self.networkMonitor = networkMonitor
        
        // Use injected session, otherwise create based on configuration
        if let injectedSession = session {
            SpaceXLogger.network("💉 Using injected URLSession")
            self.session = injectedSession
            self.certificatePinner = nil
            self.sessionDelegate = nil
        } else if configuration.enableCertificatePinning {
            // Setup certificate pinning
            SpaceXLogger.network("🔒 Certificate Pinning: ENABLED")
            let pinner = CertificatePinner.spaceXAPIPinner()
            let delegate = SecureSessionDelegate(certificatePinner: pinner)
            self.certificatePinner = pinner
            self.sessionDelegate = delegate
            
            let sessionConfig = Self.createSessionConfig(with: configuration)
            self.session = URLSession(
                configuration: sessionConfig,
                delegate: delegate,
                delegateQueue: nil
            )
        } else {
            // No certificate pinning - use shared session (bypasses all custom validation)
            SpaceXLogger.network("⚠️ Certificate Pinning: DISABLED (Development Mode) - Using URLSession.shared")
            self.certificatePinner = nil
            self.sessionDelegate = nil
            self.session = .shared
        }
    }
    
    private static func createSessionConfig(with configuration: Configuration) -> URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeoutInterval
        config.timeoutIntervalForResource = configuration.timeoutInterval * 2
        config.waitsForConnectivity = true
        config.allowsCellularAccess = true
        
        config.httpAdditionalHeaders = [
            "X-Content-Type-Options": "nosniff",
            "Referrer-Policy": "no-referrer",
            "X-Requested-With": "XMLHttpRequest"
        ]
        
        return config
    }
    
    public func request<T: Decodable & Sendable>(_ route: APIEndpoint, in environment: APIEnvironment, bypassCache: Bool = false) async throws -> T {
        // Check network connectivity before making any request
        if let networkMonitor = networkMonitor, await !networkMonitor.isConnected {
            SpaceXLogger.network("🔌 APIClient: No internet connection - throwing network error")
            throw NetworkError.networkError(URLError(.notConnectedToInternet))
        }
        
        var urlRequest = try route.urlRequest(for: environment)
        
        // Set cache policy per request
        if bypassCache {
            urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(URLError(.badServerResponse))
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            return try decoder.decode(T.self, from: data)
            
        } catch let error as DecodingError {
            throw NetworkError.decodingError(error.localizedDescription)
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            // Handle URLError specifically
            SpaceXLogger.network("🔍 APIClient caught URLError: \(urlError)")
            SpaceXLogger.network("   URLError code: \(urlError.code)")
            SpaceXLogger.network("   URLError errorCode: \(urlError.errorCode)")
            throw NetworkError.networkError(urlError)
        } catch {
            // Log the original error to understand what's happening
            SpaceXLogger.network("🔍 APIClient caught error: \(error)")
            SpaceXLogger.network("   Error type: \(type(of: error))")
            if let nsError = error as NSError? {
                SpaceXLogger.network("   Error domain: \(nsError.domain)")
                SpaceXLogger.network("   Error code: \(nsError.code)")
            }
            throw NetworkError.networkError(error)
        }
    }
}
