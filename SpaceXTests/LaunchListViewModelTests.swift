//
//  LaunchListViewModelTests.swift
//  SpaceXTests
//
//  Created by User on 6/25/25.
//

import XCTest
@testable import SpaceX
import SpaceXDomain
import SpaceXMocks

@MainActor
final class LaunchListViewModelTests: XCTestCase {
    var sut: LaunchListViewModel!
    var mockLaunchRepo: MockLaunchRepository!
    var mockRocketRepo: MockRocketRepository!
    
    override func setUp() {
        super.setUp()
        mockLaunchRepo = MockLaunchRepository()
        mockRocketRepo = MockRocketRepository()
        
        sut = LaunchListViewModel(
            launchRepository: mockLaunchRepo,
            rocketRepository: mockRocketRepo
        )
    }
    
    override func tearDown() {
        sut = nil
        mockLaunchRepo = nil
        mockRocketRepo = nil
        clearCachedFilterSortOptions()
        super.tearDown()
    }
    
    func testInitialLoadSuccess() async {
        // Given
        mockLaunchRepo.shouldThrowError = false
        
        // When
        await sut.loadLaunches()
        
        // Then
        XCTAssertFalse(sut.launches.isEmpty, "Should load launches")
        XCTAssertFalse(sut.isLoading, "Should finish loading")
        XCTAssertNil(sut.errorMessage, "Should have no error")
        XCTAssertFalse(sut.availableYears.isEmpty, "Should load filter years")
    }
    
    // MARK: - Pull to refresh
    
    func testPullToRefresh() async {
        // Given
        await sut.loadLaunches()
        let initialCount = sut.launches.count
        
        // When
        await sut.loadLaunches(forceRefresh: true)
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should finish refreshing")
        XCTAssertNil(sut.errorMessage, "Should clear any errors")
        XCTAssertEqual(sut.launches.count, initialCount, "Should load fresh data")
    }
    
    func testPullToRefreshAfterLoadingMore() async {
        // Given
        await sut.loadLaunches()
        let page1Launches = sut.launches.count
        
        // Load more
        if let lastLaunch = sut.launches.last {
            await sut.loadMoreIfNeeded(launch: lastLaunch)
        }
        let multiPageLaunches = sut.launches.count
        XCTAssertGreaterThan(multiPageLaunches, page1Launches, "Should have loaded more")
        
        // When - Pull to refresh
        await sut.loadLaunches(forceRefresh: true)
        
        // Then
        XCTAssertEqual(page1Launches, page1Launches, "Should reset to page 1")
    }
    
    // MARK: - State Management
    
    func testLoadingStates() async {
        // Given
        mockLaunchRepo.delay = 0.1
        
        // When
        let loadTask = Task {
            await sut.loadLaunches()
        }
        
        // Then
        try? await Task.sleep(nanoseconds: 50_000_000) // 0.05s
        XCTAssertTrue(sut.isLoading, "Should be loading")
        
        await loadTask.value
        XCTAssertFalse(sut.isLoading, "Should finish loading")
    }
    
    func testConcurrentLoadProtection() async {
        // Given
        mockLaunchRepo.delay = 0.2
        
        // When
        async let load1: Void = sut.loadLaunches()
        async let load2: Void = sut.loadLaunches()
        async let load3: Void = sut.loadLaunches()
        
        _ = await (load1, load2, load3)
        
        // Then
        XCTAssertFalse(sut.isLoading, "Should not be stuck loading")
        XCTAssertNotNil(sut.launches, "Should have valid launches array")
    }
    
    // MARK: - Pagination
    
    func testLoadMoreWhenNeeded() async {
        // Given
        await sut.loadLaunches()
        let initialCount = sut.launches.count
        
        // When
        if let lastLaunch = sut.launches.last {
            await sut.loadMoreIfNeeded(launch: lastLaunch)
        }
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.launches.count, initialCount, "Should maintain or increase count")
        XCTAssertFalse(sut.isLoadingMore, "Should finish loading more")
    }
    
    func testLoadMoreDoesNotTriggerForNonLastItem() async {
        // Given
        await sut.loadLaunches()
        guard sut.launches.count > 1 else { return }
        
        // When
        let firstLaunch = sut.launches.first!
        await sut.loadMoreIfNeeded(launch: firstLaunch)
        
        // Then
        XCTAssertFalse(sut.isLoadingMore, "Should not be loading more")
    }
    
    // MARK: - Sort and Filter
    
    func testFilterBySuccessfulLaunches() async {
        // Given
        await sut.loadLaunches()
        
        // When
        let filter = LaunchFilter(successStatus: .successful)
        await sut.applyFilterAndSort(filter: filter, sortOption: sut.selectedSortOption)
        
        // Then
        XCTAssertTrue(sut.launches.allSatisfy { $0.success == true }, "All launches should be successful")
        XCTAssertEqual(sut.currentFilter.successStatus, .successful, "Filter should be applied")
    }
    
    func testSortingBehavior() async {
        // Given
        await sut.loadLaunches()
        
        // When
        await sut.changeSortOption(.dateAscending)
        
        // Then
        for i in 0..<(sut.launches.count - 1) {
            XCTAssertLessThanOrEqual(sut.launches[i].dateUnix, sut.launches[i + 1].dateUnix, "Should be sorted oldest first")
        }
    }
    
    func testFilterPersistence() async {
        // Given
        let filter = LaunchFilter(years: [2024], successStatus: .successful)
        await sut.applyFilterAndSort(filter: filter, sortOption: .nameAscending)
        
        // When
        let newViewModel = LaunchListViewModel(
            launchRepository: mockLaunchRepo,
            rocketRepository: mockRocketRepo
        )
        
        // Then
        XCTAssertEqual(newViewModel.currentFilter, filter, "Should restore filter")
        XCTAssertEqual(newViewModel.selectedSortOption, .nameAscending, "Should restore sort")
    }
    
    func testResetFilterAndSort() async {
        // Given
        let filter = LaunchFilter(years: [2024], successStatus: .successful)
        await sut.applyFilterAndSort(filter: filter, sortOption: .nameAscending)
        
        // When
        await sut.resetFilterAndSort()
        
        // Then
        XCTAssertEqual(sut.currentFilter, LaunchFilter(), "Should clear filter")
        XCTAssertEqual(sut.selectedSortOption, .dateDescending, "Should reset to default sort")
    }
    
    // MARK: - Error Handling & Edge Cases
    
    func testNetworkErrorHandling() async {
        // Given
        mockLaunchRepo.shouldThrowError = true
        
        // When
        await sut.loadLaunches()
        
        // Then
        XCTAssertTrue(sut.launches.isEmpty, "Should have no data")
        XCTAssertFalse(sut.isLoading, "Should stop loading")
        XCTAssertNotNil(sut.errorMessage, "Should show error message")
    }
    
    func testErrorRecovery() async {
        // Given
        mockLaunchRepo.shouldThrowError = true
        await sut.loadLaunches()
        XCTAssertNotNil(sut.errorMessage, "Should have error")
        
        // When
        mockLaunchRepo.shouldThrowError = false
        await sut.loadLaunches(forceRefresh: true)
        
        // Then
        XCTAssertNil(sut.errorMessage, "Should clear error")
        XCTAssertFalse(sut.launches.isEmpty, "Should load data")
    }
    
    func testEmptyStateHandling() async {
        // Given
        mockLaunchRepo.mockLaunches = []
        
        // When
        await sut.loadLaunches()
        
        // Then
        XCTAssertTrue(sut.launches.isEmpty, "Should have no launches")
        XCTAssertFalse(sut.isLoading, "Should finish loading")
        XCTAssertNil(sut.errorMessage, "Should not show error for empty state")
    }
}

// MARK: - Helpers

private extension LaunchListViewModelTests {
    
    func clearCachedFilterSortOptions() {
        UserDefaults.standard.removeObject(forKey: "spacex_launch_cached_filter")
        UserDefaults.standard.removeObject(forKey: "spacex_launch_cached_sort_option")
    }
}
