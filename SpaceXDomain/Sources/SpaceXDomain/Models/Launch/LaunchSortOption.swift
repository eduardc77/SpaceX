//
//  LaunchSortOption.swift
//  SpaceXDomain
//
//  Created by User on 6/21/25.
//

public enum LaunchSortOption: String, CaseIterable, Identifiable, Codable, Sendable {
    case dateAscending = "Date (Oldest First)"
    case dateDescending = "Date (Newest First)"
    case nameAscending = "Name (A to Z)"
    case nameDescending = "Name (Z to A)"
    
    public var id: String { rawValue }
    
    public var systemImage: String {
        switch self {
        case .dateAscending:
            return "calendar.badge.plus"
        case .dateDescending:
            return "calendar.badge.minus"
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc.dottedunderline"
        }
    }
    
    public var iconName: String {
        switch self {
        case .dateAscending:
            return "arrow.up"
        case .dateDescending:
            return "arrow.down"
        case .nameAscending:
            return "textformat.abc"
        case .nameDescending:
            return "textformat.abc.dottedunderline"
        }
    }
    
    public var displayName: String {
        return rawValue
    }
    
    /// Maps domain sort options to SpaceX API sort parameters
    public var apiSortOptions: [String: String] {
        switch self {
        case .dateAscending:
            return ["date_utc": "asc"]
        case .dateDescending:
            return ["date_utc": "desc"]
        case .nameAscending:
            return ["name": "asc"]
        case .nameDescending:
            return ["name": "desc"]
        }
    }
}
