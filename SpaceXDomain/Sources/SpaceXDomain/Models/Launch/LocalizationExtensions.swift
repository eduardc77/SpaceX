//
//  LocalizationExtensions.swift
//  SpaceXDomain
//
//  Created for localization support
//

extension LaunchSortOption {
    public var localizedDisplayName: String {
        switch self {
        case .dateAscending:
            return String(localized: "sort.date.oldest_first", bundle: .module)
        case .dateDescending:
            return String(localized: "sort.date.newest_first", bundle: .module)
        case .nameAscending:
            return String(localized: "sort.name.a_to_z", bundle: .module)
        case .nameDescending:
            return String(localized: "sort.name.z_to_a", bundle: .module)
        }
    }
}

extension SuccessFilter {
    public var localizedDisplayName: String {
        switch self {
        case .all:
            return String(localized: "filter.all_launches", bundle: .module)
        case .successful:
            return String(localized: "filter.successful_only", bundle: .module)
        case .failed:
            return String(localized: "filter.failed_only", bundle: .module)
        }
    }
}

extension LaunchFilter {
    public var localizedDescription: String {
        var parts: [String] = []
        
        if !years.isEmpty {
            let sortedYears = years.sorted()
            let yearDescription = formatLocalizedYears(sortedYears)
            parts.append(yearDescription)
        }
        
        switch successStatus {
        case .successful:
            parts.append(String(localized: "status.successful", bundle: .module))
        case .failed:
            parts.append(String(localized: "status.failed", bundle: .module))
        case .all:
            break
        }
        
        return parts.isEmpty ? String(localized: "filter.all_launches", bundle: .module) : parts.joined(separator: " • ")
    }
    
    private func formatLocalizedYears(_ years: [Int]) -> String {
        return String(format: String(localized: "date.years_count", bundle: .module), years.count)
    }
}
