//
//  DateExtensions.swift
//  SpaceXUtilities
//
//  Created by User on 6/21/25.
//

import Foundation

public extension DateFormatter {
    /// DateFormatter for parsing SpaceX API date strings (ISO 8601 format)
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// DateFormatter for displaying dates in a user-friendly format
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

public extension Date {
    
    /// Returns a string describing the number of days from now, with logic for upcoming launches
    func daysFromNow(isUpcoming: Bool) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: self)
        
        guard let days = components.day else { return "" }
        
        if days > 0 {
            return String(format: String(localized: "date.days_from_now", bundle: .main), days)
        } else if days < 0 {
            // For upcoming launches with past dates
            if isUpcoming {
                return String(localized: "date.pending", bundle: .main)
            }
            return String(format: String(localized: "date.days_since_now", bundle: .main), abs(days))
        } else {
            return String(localized: "date.today", bundle: .main)
        }
    }
    
    /// Extracts the year component from a date
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
}

public extension String {
    /// Parses a SpaceX API date string into a Date object
    func toSpaceXDate() -> Date? {
        return DateFormatter.apiDateFormatter.date(from: self)
    }
}

public extension Array where Element == Date {
    /// Extracts unique years from an array of dates
    var uniqueYears: Set<Int> {
        Set(self.map(\.year))
    }
}
