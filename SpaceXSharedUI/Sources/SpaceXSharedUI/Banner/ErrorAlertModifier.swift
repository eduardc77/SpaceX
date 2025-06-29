//
//  ErrorAlertModifier.swift
//  SpaceXSharedUI
//
//  Created by User on 6/28/25.
//

import SwiftUI
import SpaceXDomain

public struct ErrorAlertModifier: ViewModifier {
    @Binding var error: AppError?
    let onRetry: (() async -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .alert(
                error?.alertTitle ?? String(localized: "error.generic.title", bundle: .module),
                isPresented: Binding(
                    get: { error != nil && error?.shouldShowAsAlert == true },
                    set: { _ in }
                ),
                presenting: error
            ) { error in
                Button(String(localized: "action.ok", bundle: .module), role: .cancel) {}
                
                // Show additional action for certificate errors
                if error == .certificatePinningFailure {
                    Button(String(localized: "action.open_settings", bundle: .module)) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            } message: { error in
                Text(error.alertMessage)
            }
    }
}

public extension View {
    func errorAlert(_ error: Binding<AppError?>, onRetry: (() async -> Void)? = nil) -> some View {
        modifier(ErrorAlertModifier(error: error, onRetry: onRetry))
    }
}

public extension AppError {
    
    var shouldShowAsAlert: Bool {
        switch self {
        case .certificatePinningFailure:
            return true // Security critical
        case .serverError(let code) where code >= 500:
            return true // Server errors should be prominent
        case .dataCorrupted:
            return true
        case .networkUnavailable:
            return true // Network errors
        default:
            return false
        }
    }
    
    var alertMessage: String {
        switch self {
        case .certificatePinningFailure:
            return String(localized: "error.certificate.message", bundle: .module)
        case .serverError(let code):
            let format = String(localized: "error.server.message", bundle: .module)
            return String(format: format, code)
        case .dataCorrupted:
            return String(localized: "error.data_corrupted.message", bundle: .module)
        default:
            return userMessage
        }
    }
    
    var alertTitle: String {
        switch self {
        case .certificatePinningFailure:
            return String(localized: "error.security.title", bundle: .module)
        case .serverError:
            return String(localized: "error.server.title", bundle: .module)
        case .dataCorrupted:
            return String(localized: "error.data.title", bundle: .module)
        case .networkUnavailable:
            return String(localized: "error.network.title", bundle: .module)
        case .unknown:
            return String(localized: "error.generic.title", bundle: .module)
        }
    }
}
