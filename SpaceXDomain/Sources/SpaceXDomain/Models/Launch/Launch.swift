//
//  Launch.swift
//  SpaceXDomain
//
//  Created by User on 6/20/25.
//

import SwiftUI
import SpaceXUtilities

public struct Launch: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let details: String?
    public let upcoming: Bool
    public let success: Bool?
    public let dateUtc: String
    public let dateUnix: Int
    public let links: LaunchLinks
    public let rocket: String
    public let flightNumber: Int
    public let cores: [LaunchCore]
    
    public init(
        id: String,
        name: String,
        details: String? = nil,
        upcoming: Bool,
        success: Bool? = nil,
        dateUtc: String,
        dateUnix: Int,
        links: LaunchLinks,
        rocket: String,
        flightNumber: Int,
        cores: [LaunchCore]
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.upcoming = upcoming
        self.success = success
        self.dateUtc = dateUtc
        self.dateUnix = dateUnix
        self.links = links
        self.rocket = rocket
        self.flightNumber = flightNumber
        self.cores = cores
    }
}

public extension Launch {
    /// Formatted date string for display (e.g., "Mar 24, 2006 at 10:30 PM")
    var formattedDate: String {
        guard let date = dateUtc.toSpaceXDate() else { return dateUtc }
        return DateFormatter.displayDateFormatter.string(from: date)
    }
    
    /// Days from/since now text (e.g., "5 days from now", "100 days since now")
    var daysFromNowText: String {
        guard let launchDate = dateUtc.toSpaceXDate() else { return "Invalid date" }
        return launchDate.daysFromNow(isUpcoming: upcoming)
    }
    
    /// Extract year from launch date for filtering/grouping
    var year: Int? {
        // Try proper ISO8601 parsing first (best practice)
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateUtc) {
            return Calendar.current.component(.year, from: date)
        }
        
        // Fallback to string extraction for malformed dates
        guard dateUtc.count >= 4,
              let year = Int(String(dateUtc.prefix(4))) else {
            return nil
        }
        return year
    }
    
    // MARK: - UI Representation
    
    var statusIcon: String {
        if upcoming {
            return "clock.circle.fill"
        } else if let success = success {
            return success ? "checkmark.circle.fill" : "xmark.circle.fill"
        } else {
            return "questionmark.circle.fill"
        }
    }
    
    var statusIconSimple: String {
        if upcoming {
            return "clock"
        } else if let success = success {
            return success ? "checkmark" : "xmark"
        } else {
            return "questionmark"
        }
    }
    
    var statusColor: Color {
        if upcoming {
            return .blue
        } else if let success = success {
            return success ? .green : .red
        } else {
            return .gray
        }
    }
    
    var statusText: LocalizedStringKey {
        switch success {
        case .none:
            return .statusUpcoming
        case .some(let success):
            return success ? .statusSuccessful : .statusFailed
        }
    }
}

public struct PaginatedLaunches: Sendable {
    public let launches: [Launch]
    public let totalCount: Int
    public let currentPage: Int
    public let totalPages: Int
    public let hasNextPage: Bool
    public let hasPrevPage: Bool
    public let pageSize: Int
    
    public init(
        launches: [Launch],
        totalCount: Int,
        currentPage: Int,
        totalPages: Int,
        hasNextPage: Bool,
        hasPrevPage: Bool,
        pageSize: Int
    ) {
        self.launches = launches
        self.totalCount = totalCount
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.hasNextPage = hasNextPage
        self.hasPrevPage = hasPrevPage
        self.pageSize = pageSize
    }
}
