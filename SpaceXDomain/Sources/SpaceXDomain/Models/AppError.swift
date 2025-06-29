import Foundation
import SpaceXUtilities

public enum AppError: Error, Sendable, Equatable {
    case networkUnavailable
    case certificatePinningFailure
    case serverError(Int)
    case dataCorrupted
    case unknown(String)
    
    public var userMessage: String {
        switch self {
        case .certificatePinningFailure:
            return "Unable to establish a secure connection. Please check your network settings."
        case .networkUnavailable:
            return "Network connection failed. Please check your internet connection."
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .dataCorrupted:
            return "Unable to process server response"
        case .unknown(let message):
            return message
        }
    }
    
    public var iconName: String {
        switch self {
        case .certificatePinningFailure:
            return "lock.trianglebadge.exclamationmark"
        case .networkUnavailable:
            return "wifi.exclamationmark"
        case .serverError:
            return "server.rack"
        case .dataCorrupted:
            return "exclamationmark.triangle"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    public var iconColor: String {
        switch self {
        case .certificatePinningFailure:
            return "red"
        case .networkUnavailable:
            return "orange"
        case .serverError:
            return "red"
        case .dataCorrupted:
            return "yellow"
        case .unknown:
            return "gray"
        }
    }
    
    public var isCertificatePinningFailure: Bool {
        if case .certificatePinningFailure = self {
            return true
        }
        return false
    }
}

// MARK: - Error Mapping Helpers

public extension AppError {
    /// Maps a generic Error to AppError based on error characteristics
    static func from(_ error: Error) -> AppError {
        // Try URLError detection first
        if let appError = mapURLError(error) {
            return appError
        }
        
        // Try NSError detection
        if let appError = mapNSError(error) {
            return appError
        }
        
        // Try string-based detection for wrapped errors
        if let appError = mapWrappedError(error) {
            return appError
        }
        
        // Default to unknown
        return .unknown(error.localizedDescription)
    }
    
    private static func mapURLError(_ error: Error) -> AppError? {
        guard let urlError = error as? URLError else { return nil }
        
        SpaceXLogger.error("   ✅ Detected as URLError with code: \(urlError.code)")
        
        if isCertificateError(urlError.code) {
            SpaceXLogger.error("   ✅ Detected as certificate pinning failure")
            return .certificatePinningFailure
        }
        
        if isNetworkConnectivityError(urlError.code) {
            return .networkUnavailable
        }
        
        // Check if it's wrapped in NetworkError
        let errorString = String(describing: error)
        if errorString.contains("networkError") && urlError.code == .cancelled {
            SpaceXLogger.error("   ✅ Detected as certificate pinning failure (wrapped)")
            return .certificatePinningFailure
        }
        
        return .networkUnavailable
    }
    
    private static func mapNSError(_ error: Error) -> AppError? {
        let nsError = error as NSError
        
        // Check for explicit certificate errors (highest priority)
        if nsError.domain == NSURLErrorDomain && isCertificateErrorCode(nsError.code) {
            SpaceXLogger.error("   ✅ Detected as certificate pinning failure")
            return .certificatePinningFailure
        }
        
        // Check for network connectivity issues
        if isNetworkConnectivityErrorCode(nsError.code) {
            return .networkUnavailable
        }
        
        return nil
    }
    
    private static func mapWrappedError(_ error: Error) -> AppError? {
        let errorString = String(describing: error)
        
        // Check if it's wrapped certificate pinning error
        if errorString.contains("networkError") && errorString.contains("cancelled") {
            SpaceXLogger.error("   ✅ Detected as wrapped cancelled error - likely certificate pinning failure")
            return .certificatePinningFailure
        }
        
        // Check for HTTP errors
        if errorString.contains("httpError") {
            if let httpCode = extractHTTPStatusCode(from: errorString) {
                return .serverError(httpCode)
            }
        }
        
        // Check for decoding errors
        if errorString.contains("decodingError") {
            return .dataCorrupted
        }
        
        return nil
    }
    
    private static func isCertificateError(_ code: URLError.Code) -> Bool {
        switch code {
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
    
    private static func isNetworkConnectivityError(_ code: URLError.Code) -> Bool {
        switch code {
        case .notConnectedToInternet,
                .networkConnectionLost,
                .timedOut:
            return true
        default:
            return false
        }
    }
    
    private static func isCertificateErrorCode(_ code: Int) -> Bool {
        return code == NSURLErrorCancelled ||
        code == NSURLErrorServerCertificateUntrusted ||
        code == NSURLErrorServerCertificateHasBadDate ||
        code == NSURLErrorServerCertificateNotYetValid ||
        code == NSURLErrorSecureConnectionFailed
    }
    
    private static func isNetworkConnectivityErrorCode(_ code: Int) -> Bool {
        return code == NSURLErrorNotConnectedToInternet ||
        code == NSURLErrorNetworkConnectionLost ||
        code == NSURLErrorTimedOut
    }
    
    private static func extractHTTPStatusCode(from errorString: String) -> Int? {
        // Extract HTTP status code from error string like "httpError(404)"
        let pattern = "httpError\\((\\d+)\\)"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = errorString as NSString
        let results = regex?.matches(in: errorString, range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first,
           match.numberOfRanges > 1 {
            let range = match.range(at: 1)
            let codeString = nsString.substring(with: range)
            return Int(codeString)
        }
        
        return nil
    }
} 
