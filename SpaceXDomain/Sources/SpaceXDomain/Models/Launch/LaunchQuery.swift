//
//  LaunchQuery.swift
//  SpaceXDomain
//
//  Created by User on 6/24/25.
//

public struct LaunchQuery: Codable, Sendable {
    public let query: LaunchQueryFilter?
    public let options: QueryOptions
    
    public init(query: LaunchQueryFilter? = nil, options: QueryOptions) {
        self.query = query
        self.options = options
    }
}

public struct LaunchQueryFilter: Codable, Sendable {
    public let success: Bool?
    public let dateUtc: DateQuery?
    public let or: [LaunchQueryFilter]?
    
    public init(success: Bool? = nil, dateUtc: DateQuery? = nil, or: [LaunchQueryFilter]? = nil) {
        self.success = success
        self.dateUtc = dateUtc
        self.or = or
    }
    
    private enum CodingKeys: String, CodingKey {
        case success
        case dateUtc
        case or = "$or"
    }
}

public enum DateQuery: Codable, Sendable {
    case range(DateRange)
    case regex(String)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .range(let dateRange):
            try container.encode(dateRange)
        case .regex(let pattern):
            try container.encode(["$regex": pattern])
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dateRange = try? container.decode(DateRange.self) {
            self = .range(dateRange)
        } else if let regexDict = try? container.decode([String: String].self),
                  let pattern = regexDict["$regex"] {
            self = .regex(pattern)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid DateQuery format")
            )
        }
    }
}

public struct DateRange: Codable, Sendable {
    public let gte: String?  // Greater than or equal
    public let lt: String?   // Less than
    
    public init(gte: String? = nil, lt: String? = nil) {
        self.gte = gte
        self.lt = lt
    }
    
    private enum CodingKeys: String, CodingKey {
        case gte = "$gte"
        case lt = "$lt"
    }
}

public struct QueryOptions: Codable, Sendable {
    public let limit: Int
    public let page: Int
    public let sort: [String: String]?
    public let select: [String: Int]?
    
    public init(limit: Int = 20, page: Int = 1, sort: [String: String]? = nil, select: [String: Int]? = nil) {
        self.limit = limit
        self.page = page
        self.sort = sort
        self.select = select
    }
}

// MARK: - Query Validation

extension LaunchQuery {
    
    /// Validates the query before sending to API
    public func validate() throws {
        try validatePagination()
        try validateFilters()
    }
    
    private func validatePagination() throws {
        guard options.limit > 0, options.limit <= 100 else {
            throw QueryError.invalidPageSize
        }
        
        guard options.page > 0 else {
            throw QueryError.invalidPage
        }
    }
    
    private func validateFilters() throws {
        // Add filter validation if needed
        if let query = query {
            try validateQueryFilter(query)
        }
    }
    
    private func validateQueryFilter(_ filter: LaunchQueryFilter) throws {
        // Validate nested OR filters
        if let orFilters = filter.or {
            guard !orFilters.isEmpty, orFilters.count <= 20 else {
                throw QueryError.tooManyOrConditions
            }
            
            for orFilter in orFilters {
                try validateQueryFilter(orFilter)
            }
        }
    }
}

// MARK: - Query Errors

public enum QueryError: Error {
    case invalidPageSize
    case invalidPage
    case tooManyOrConditions
    case invalidDateFormat
    
    public var errorDescription: String? {
        switch self {
        case .invalidPageSize:
            return "Page size must be between 1 and 100"
        case .invalidPage:
            return "Page must be greater than 0"
        case .tooManyOrConditions:
            return "Too many OR conditions in query"
        case .invalidDateFormat:
            return "Invalid date format in query"
        }
    }
}
