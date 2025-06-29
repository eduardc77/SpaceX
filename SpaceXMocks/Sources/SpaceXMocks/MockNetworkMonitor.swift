//
//  MockNetworkMonitor.swift
//  SpaceXMocks
//
//  Created by User on 6/27/25.
//

import Observation
import Network
import SpaceXUtilities

@Observable
@MainActor
public final class MockNetworkMonitor: NetworkMonitoring {
    public private(set) var status = NetworkStatus()
    public private(set) var isMonitoring = false
    
    public var isConnected: Bool { status.isConnected }
    public var isExpensive: Bool { status.isExpensive }
    public var connectionType: NWInterface.InterfaceType? { status.connectionType }
    public var connectionDescription: String { status.connectionDescription }
    public var isWiFi: Bool { status.isWiFi }
    public var isCellular: Bool { status.isCellular }
    
    public init() {
        // Set default connected state
        status = NetworkStatus(isConnected: true, isExpensive: false, connectionType: .wifi)
    }
    
    public func startMonitoring() {
        isMonitoring = true
    }
    
    public func simulateNetworkUnavailable() {
        status = NetworkStatus(isConnected: false, isExpensive: false, connectionType: nil)
    }
    
    public func simulateNetworkConnected() {
        status = NetworkStatus(isConnected: true, isExpensive: false, connectionType: .wifi)
    }
    
    public func simulateCellularConnection() {
        status = NetworkStatus(isConnected: true, isExpensive: true, connectionType: .cellular)
    }
} 
