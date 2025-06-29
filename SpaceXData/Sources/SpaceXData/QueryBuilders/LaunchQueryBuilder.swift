//
//  LaunchQueryBuilder.swift
//  SpaceXData
//
//  Created by User on 6/29/25.
//

import SpaceXDomain
import SpaceXUtilities

struct LaunchQueryBuilder {
    private var yearFilters: [LaunchQueryFilter] = []
    private var successFilter: LaunchQueryFilter?
    
    func withYearsIfNeeded(_ years: Set<Int>) -> Self {
        guard !years.isEmpty else { return self }
        
        var builder = self
        builder.yearFilters = years
            .sorted()
            .compactMap { year in
                guard Self.isValidYear(year) else {
                    SpaceXLogger.error("Invalid year for filtering: \(year)")
                    return nil
                }
                return LaunchQueryFilter(dateUtc: .regex(Self.buildYearRegex(year)))
            }
        return builder
    }
    
    func withSuccessIfNeeded(_ successStatus: SuccessFilter) -> Self {
        guard successStatus != .all else { return self }
        
        var builder = self
        let isSuccessful = successStatus == .successful
        builder.successFilter = LaunchQueryFilter(success: isSuccessful)
        return builder
    }
    
    func build() -> LaunchQueryFilter? {
        let hasYears = !yearFilters.isEmpty
        let hasSuccess = successFilter != nil
        
        switch (hasYears, hasSuccess) {
        case (false, false):
            return nil
            
        case (true, false):
            // Years only
            return LaunchQueryFilter(or: yearFilters)
            
        case (false, true):
            // Success only
            return successFilter
            
        case (true, true):
            // Combine years with success using AND logic
            guard let success = successFilter else { return nil }
            
            let combinedFilters = yearFilters.map { yearFilter in
                LaunchQueryFilter(
                    success: success.success,
                    dateUtc: yearFilter.dateUtc
                )
            }
            return LaunchQueryFilter(or: combinedFilters)
        }
    }
    
    // MARK: - Helper Methods
    
    private static func isValidYear(_ year: Int) -> Bool {
        year >= 1957 && year <= 2050 // SpaceX era + reasonable future
    }
    
    private static func buildYearRegex(_ year: Int) -> String {
        "^\(year)-" // ISO date format starts with year
    }
}
