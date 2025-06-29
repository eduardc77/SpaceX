//
//  SpaceXLogger.swift
//  SpaceXUtilities
//
//  Centralized logging system
//

import OSLog

public struct SpaceXLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.spacex.app"
    
    public static let networking = Logger(subsystem: subsystem, category: "networking")
    public static let data = Logger(subsystem: subsystem, category: "data")
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    public static let cache = Logger(subsystem: subsystem, category: "cache")
    public static let security = Logger(subsystem: subsystem, category: "security")
    public static let general = Logger(subsystem: subsystem, category: "general")
    
    public static func network(_ message: String) {
    #if DEBUG
        networking.debug("🌐 \(message)")
    #else
        networking.info("🌐 \(message)")
    #endif
    }
    
    public static func cacheOperation(_ message: String) {
    #if DEBUG
        cache.debug("💾 \(message, privacy: .private)")
    #endif
    }
    
    public static func error(_ message: String, category: Logger = general) {
        category.error("❌ \(message, privacy: .public)")
    }
    
    public static func success(_ message: String, category: Logger = general) {
    #if DEBUG
        category.debug("✅ \(message, privacy: .public)")
    #endif
    }
    
    public static func ui(_ message: String) {
    #if DEBUG
        ui.debug("🎨 \(message, privacy: .public)")
    #endif
    }
    
    // MARK: - Network Request/Response Logging
    
    public static func logRequest(_ request: URLRequest) {
    #if DEBUG
        guard let url = request.url else { return }
        networking.debug("🌐 Request: \(url.absoluteString, privacy: .public)")
        
        if let method = request.httpMethod {
            networking.debug("📋 Method: \(method, privacy: .public)")
        }
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            let sanitized = sanitizeHeaders(headers)
            networking.debug("📄 Headers: \(sanitized, privacy: .private)")
        }
    #endif
    }
    
    public static func logResponse(_ response: HTTPURLResponse, data: Data?) {
    #if DEBUG
        networking.debug("📥 Response: \(response.statusCode) - \(response.url?.absoluteString ?? "unknown", privacy: .public)")
        
        if let data = data, data.count < 1000 { // Only log small responses
            if let text = String(data: data, encoding: .utf8) {
                networking.debug("📄 Body preview: \(text.prefix(200), privacy: .private)")
            }
        }
    #endif
    }
    
    private static func sanitizeHeaders(_ headers: [String: String]) -> String {
        var sanitized = headers
        let sensitiveKeys = ["Authorization", "Cookie", "Set-Cookie", "X-API-Key"]
        
        for key in sensitiveKeys where sanitized[key] != nil {
            sanitized[key] = "***REDACTED***"
        }
        return sanitized.description
    }
}
