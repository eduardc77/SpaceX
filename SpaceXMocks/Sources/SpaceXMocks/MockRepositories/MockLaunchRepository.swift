//
//  MockLaunchRepository.swift
//  SpaceXMocks
//
//  Created by User on 6/24/25.
//

import Foundation
import SpaceXDomain

public class MockLaunchRepository: LaunchRepositoryProtocol {
    public var shouldThrowError = false
    public var mockLaunches: [Launch] = MockLaunchData.launches
    public var delay: TimeInterval = 0.5
    public var yearsFetchDelay: TimeInterval = 0.2

    public init() {}

    public func getLaunches(
        page: Int,
        pageSize: Int,
        sortOption: LaunchSortOption,
        filter: LaunchFilter,
        forceRefresh: Bool
    ) async throws -> PaginatedLaunches {

        // Simulate network delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }

        let filteredLaunches = applyFiltersAndSort(to: mockLaunches, filter: filter, sortOption: sortOption)
        return createPaginatedResult(from: filteredLaunches, page: page, pageSize: pageSize)
    }

    public func getAvailableYears() async throws -> [Int] {
        // Simulate lighter network delay for years-only fetch
        try await Task.sleep(nanoseconds: UInt64(yearsFetchDelay * 1_000_000_000))

        if shouldThrowError {
            throw NetworkError.networkError(URLError(.networkConnectionLost))
        }

        // Extract years from mock data
        let years = Set(mockLaunches.compactMap { launch in
            launch.year
        })

        return Array(years).sorted(by: >)
    }
    
    // MARK: - Helpers

    private func applyFiltersAndSort(to launches: [Launch], filter: LaunchFilter, sortOption: LaunchSortOption) -> [Launch] {
        var result = applySuccessFilter(to: launches, filter: filter)
        result = applyYearFilter(to: result, filter: filter)
        return applySorting(to: result, sortOption: sortOption)
    }
    
    private func applySuccessFilter(to launches: [Launch], filter: LaunchFilter) -> [Launch] {
        switch filter.successStatus {
        case .successful:
            return launches.filter { $0.success == true }
        case .failed:
            return launches.filter { $0.success == false }
        case .all:
            return launches
        }
    }
    
    private func applyYearFilter(to launches: [Launch], filter: LaunchFilter) -> [Launch] {
        guard !filter.years.isEmpty else { return launches }
        
        return launches.filter { launch in
            guard let year = launch.year else { return false }
            return filter.years.contains(year)
        }
    }
    
    private func applySorting(to launches: [Launch], sortOption: LaunchSortOption) -> [Launch] {
        switch sortOption {
        case .dateAscending:
            return launches.sorted { $0.dateUtc < $1.dateUtc }
        case .dateDescending:
            return launches.sorted { $0.dateUtc > $1.dateUtc }
        case .nameAscending:
            return launches.sorted { $0.name < $1.name }
        case .nameDescending:
            return launches.sorted { $0.name > $1.name }
        }
    }
    
    private func createPaginatedResult(from launches: [Launch], page: Int, pageSize: Int) -> PaginatedLaunches {
        let totalCount = launches.count
        let totalPages = (totalCount + pageSize - 1) / pageSize
        let startIndex = (page - 1) * pageSize
        let endIndex = min(startIndex + pageSize, totalCount)
        
        guard startIndex < totalCount else {
            return PaginatedLaunches(
                launches: [],
                totalCount: totalCount,
                currentPage: page,
                totalPages: totalPages,
                hasNextPage: false,
                hasPrevPage: page > 1,
                pageSize: pageSize
            )
        }
        
        let paginatedLaunches = Array(launches[startIndex..<endIndex])
        let hasNextPage = endIndex < totalCount
        let hasPrevPage = page > 1
        
        return PaginatedLaunches(
            launches: paginatedLaunches,
            totalCount: totalCount,
            currentPage: page,
            totalPages: totalPages,
            hasNextPage: hasNextPage,
            hasPrevPage: hasPrevPage,
            pageSize: pageSize
        )
    }
}
