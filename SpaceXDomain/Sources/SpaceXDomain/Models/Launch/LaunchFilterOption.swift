//
//  LaunchFilterOption.swift
//  SpaceXDomain
//
//  Created by User on 6/22/25.
//

public struct LaunchFilter: Codable, Sendable, Equatable {
    public let years: Set<Int>
    public let successStatus: SuccessFilter
    
    public init(years: Set<Int> = [], successStatus: SuccessFilter = .all) {
        self.years = years
        self.successStatus = successStatus
    }
    
    public var isActive: Bool {
        return !years.isEmpty || successStatus != .all
    }
    
    public var description: String {
        var parts: [String] = []
        
        if !years.isEmpty {
            let sortedYears = years.sorted()
            let yearDescription = formatYears(sortedYears)
            parts.append(yearDescription)
        }
        
        switch successStatus {
        case .successful:
            parts.append("Successful")
        case .failed:
            parts.append("Failed")
        case .all:
            break
        }
        
        return parts.isEmpty ? "All Launches" : parts.joined(separator: " • ")
    }
    
    private func formatYears(_ years: [Int]) -> String {
        switch years.count {
        case 1:
            return String(years[0])
        case 2:
            return "\(years[0]), \(years[1])"
        case 3:
            return "\(years[0]), \(years[1]), \(years[2])"
        default:
            return "\(years.count) years"
        }
    }
}

public enum SuccessFilter: String, CaseIterable, Codable, Sendable {
    case all = "All Launches"
    case successful = "Successful Only"
    case failed = "Failed Only"
    
    public var displayName: String {
        return rawValue
    }
    
    public var systemImage: String {
        switch self {
        case .all:
            return "circle"
        case .successful:
            return "checkmark.circle.fill"
        case .failed:
            return "xmark.circle.fill"
        }
    }
}
