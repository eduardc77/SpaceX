//
//  LocalizedStringKey+SharedUI.swift
//  SpaceXSharedUI
//
//  Created by User on 6/27/25.
//

import SwiftUI

public extension LocalizedStringKey {
    
    // MARK: - Error Alerts (Shared UI)
    static var errorGenericTitle: LocalizedStringKey { "error.generic.title" }
    static var errorSecurityTitle: LocalizedStringKey { "error.security.title" }
    static var errorServerTitle: LocalizedStringKey { "error.server.title" }
    static var errorDataTitle: LocalizedStringKey { "error.data.title" }
    static var errorNetworkTitle: LocalizedStringKey { "error.network.title" }
    
    // MARK: - Error Messages
    static var errorCertificateMessage: LocalizedStringKey { "error.certificate.message" }
    static var errorServerMessage: LocalizedStringKey { "error.server.message" }
    static var errorDataCorruptedMessage: LocalizedStringKey { "error.data_corrupted.message" }
    
    // MARK: - Network Status
    static var networkNoConnection: LocalizedStringKey { "network.no_connection" }
    static var networkCachedData: LocalizedStringKey { "network.cached_data" }
    
    // MARK: - Alert Actions (Shared UI)
    static var actionOk: LocalizedStringKey { "action.ok" }
    static var actionOpenSettings: LocalizedStringKey { "action.open_settings" }
}
