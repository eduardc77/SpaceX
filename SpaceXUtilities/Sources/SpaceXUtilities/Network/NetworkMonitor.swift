//
//  NetworkMonitor.swift
//  SpaceXUtilities
//
//  Created by User on 6/24/25.
//

import Foundation
import Network

@MainActor
public protocol NetworkMonitoring: Sendable {
    var isConnected: Bool { get }
    var isExpensive: Bool { get }
    var connectionType: NWInterface.InterfaceType? { get }
}

@Observable
@MainActor
public final class NetworkMonitor {
    public private(set) var status = NetworkStatus()
    public private(set) var isMonitoring = false
    
    @ObservationIgnored private let pathMonitor = NWPathMonitor()
    @ObservationIgnored private let queue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    
    public init() {
        setupMonitoring()
        startMonitoring()
    }
    
    deinit {
        pathMonitor.cancel()
    }
    
    public func startMonitoring() {
        guard !isMonitoring else { return }
        
        pathMonitor.start(queue: queue)
        isMonitoring = true
    }
    
    private func setupMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            let newStatus = NetworkStatus(
                isConnected: path.status == .satisfied,
                isExpensive: path.isExpensive,
                connectionType: self?.getConnectionType(from: path)
            )
            
            Task { @MainActor [weak self] in
                self?.status = newStatus
            }
        }
    }
    
    private nonisolated func getConnectionType(from path: NWPath) -> NWInterface.InterfaceType? {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wiredEthernet
        } else if path.usesInterfaceType(.loopback) {
            return .loopback
        }
        return nil
    }
}

extension NetworkMonitor: NetworkMonitoring {
    public var isConnected: Bool { status.isConnected }
    public var isExpensive: Bool { status.isExpensive }
    public var connectionType: NWInterface.InterfaceType? { status.connectionType }
    public var connectionDescription: String { status.connectionDescription }
    public var isWiFi: Bool { status.isWiFi }
    public var isCellular: Bool { status.isCellular }
}

public struct NetworkStatus: Sendable, Equatable {
    public let isConnected: Bool
    public let isExpensive: Bool
    public let connectionType: NWInterface.InterfaceType?
    
    public init(
        isConnected: Bool = false,
        isExpensive: Bool = false,
        connectionType: NWInterface.InterfaceType? = nil
    ) {
        self.isConnected = isConnected
        self.isExpensive = isExpensive
        self.connectionType = connectionType
    }
    
    public var connectionDescription: String {
        guard isConnected else { return "No Connection" }
        
        let type = connectionType?.displayName ?? "Unknown"
        let cost = isExpensive ? " (Limited Data)" : ""
        return "\(type)\(cost)"
    }
    
    public var isWiFi: Bool {
        isConnected && connectionType == .wifi
    }
    
    public var isCellular: Bool {
        isConnected && connectionType == .cellular
    }
}

extension NWInterface.InterfaceType {
    public var displayName: String {
        switch self {
        case .wifi:
            return "Wi-Fi"
        case .cellular:
            return "Cellular"
        case .wiredEthernet:
            return "Ethernet"
        case .loopback:
            return "Loopback"
        case .other:
            return "Other"
        @unknown default:
            return "Unknown"
        }
    }
}
