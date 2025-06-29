//
//  LocalizedStringKey+Domain.swift
//  SpaceXDomain
//
//  Created by User on 6/27/25.
//

import SwiftUI

public extension LocalizedStringKey {
    
    // MARK: - Filter Options (Domain Data)
    static var filterAllLaunches: LocalizedStringKey { "filter.all_launches" }
    static var filterSuccessfulOnly: LocalizedStringKey { "filter.successful_only" }
    static var filterFailedOnly: LocalizedStringKey { "filter.failed_only" }
    
    // MARK: - Sort Options (Domain Data)
    static var sortDateOldestFirst: LocalizedStringKey { "sort.date.oldest_first" }
    static var sortDateNewestFirst: LocalizedStringKey { "sort.date.newest_first" }
    static var sortNameAToZ: LocalizedStringKey { "sort.name.a_to_z" }
    static var sortNameZToA: LocalizedStringKey { "sort.name.z_to_a" }
    
    // MARK: - Domain Status
    static var statusFailedDomain: LocalizedStringKey { "status.failed" }
    static var statusSuccessfulDomain: LocalizedStringKey { "status.successful" }
    
    // MARK: - Status
    static var statusUpcoming: LocalizedStringKey { "status.upcoming" }
    static var statusSuccess: LocalizedStringKey { "status.success" }
    static var statusFailure: LocalizedStringKey { "status.failure" }
    static var statusUnknown: LocalizedStringKey { "status.unknown" }
    static var statusSuccessful: LocalizedStringKey { "status.successful" }
    static var statusFailed: LocalizedStringKey { "status.failed" }
    
    // MARK: - Dynamic String Helpers (Domain Bundle)
    static func dateYearsCountDomain(_ years: Int) -> String {
        String(format: String(localized: "date.years_count", bundle: .module), years)
    }
}
