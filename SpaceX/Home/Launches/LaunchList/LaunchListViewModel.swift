//
//  LaunchListViewModel.swift
//  SpaceX
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain
import SpaceXUtilities

@Observable
@MainActor
final class LaunchListViewModel {
    var launches: [Launch] = []
    var rocketNames: [String: String] = [:]
    var isLoading = true
    var isLoadingMore = false
    var currentError: AppError?
    var selectedSortOption: LaunchSortOption
    var currentFilter: LaunchFilter = LaunchFilter()
    var availableYears: [Int] = []
    
    @ObservationIgnored private let launchRepository: LaunchRepositoryProtocol
    @ObservationIgnored private let rocketRepository: RocketRepositoryProtocol
    
    // MARK: - Task Management
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    @ObservationIgnored private var loadMoreTask: Task<Void, Never>?
    
    // MARK: - Pagination
    @ObservationIgnored private var currentPage = 1
    @ObservationIgnored private var hasMorePages = true
    @ObservationIgnored private let pageSize = 20
    
    @ObservationIgnored private let maxCachedLaunches = 500 // Prevent unlimited memory growth
    
    @ObservationIgnored private let maxCachedRocketNames = 50 // Limit rocket names cache

    // MARK: - Persistence Keys
    @ObservationIgnored private let sortOptionKey = "spacex_launch_cached_sort_option"
    @ObservationIgnored private let filterKey = "spacex_launch_cached_filter"
    
    var canLoadMore: Bool {
        !isLoading && !isLoadingMore && hasMorePages && loadTask == nil
    }
    
    var errorMessage: String? {
        currentError?.userMessage
    }
    
    init(launchRepository: LaunchRepositoryProtocol,
         rocketRepository: RocketRepositoryProtocol) {
        self.launchRepository = launchRepository
        self.rocketRepository = rocketRepository
        
        self.selectedSortOption = .dateDescending
        self.currentFilter = LaunchFilter()
        
        // Restore saved preferences
        self.selectedSortOption = restoreSortOption()
        self.currentFilter = restoreFilter()
    }
    
    func loadLaunches(forceRefresh: Bool = false) async {
        if forceRefresh {
            cancelAllTasks()
            resetPagination()
            currentError = nil
        } else if loadTask != nil { return }
        
        let task = Task {
            isLoading = true
            
            do {
                try Task.checkCancellation()
                
                let result = try await launchRepository.getLaunches(
                    page: currentPage,
                    pageSize: pageSize,
                    sortOption: selectedSortOption,
                    filter: currentFilter,
                    forceRefresh: forceRefresh
                )
                
                try Task.checkCancellation()
                
                launches = result.launches
                currentPage = result.currentPage
                hasMorePages = result.hasNextPage
                await loadRocketNames()
                
                // Load available years only on first page or force refresh
                if currentPage == 1 && (availableYears.isEmpty || forceRefresh) {
                    await loadAvailableYears()
                }
                
            } catch is CancellationError {
                SpaceXLogger.network("🔄 Load task was cancelled")
            } catch let appError as AppError {
                SpaceXLogger.error("❌ LaunchListViewModel caught AppError: \(appError)")
                currentError = appError
            } catch {
                SpaceXLogger.error("❌ LaunchListViewModel caught generic error: \(error)")
                SpaceXLogger.error("   Error type: \(type(of: error))")
                currentError = AppError.from(error)
                SpaceXLogger.error("   Mapped to AppError: \(String(describing: currentError))")
            }
            
            isLoading = false
            loadTask = nil
        }
        
        loadTask = task
        await task.value
    }
    
    func loadMoreIfNeeded(launch: Launch) async {
        guard canLoadMore,
              let lastLaunch = launches.last,
              lastLaunch.id == launch.id else { return }
        
        await loadMoreLaunches()
    }
    
    func applyFilterAndSort(filter: LaunchFilter, sortOption: LaunchSortOption) async {
        currentFilter = filter
        selectedSortOption = sortOption
        
        saveFilter(filter)
        saveSortOption(sortOption)
        
        resetPagination()
        await loadLaunches(forceRefresh: false)
    }
    
    func resetFilterAndSort() async {
        currentFilter = LaunchFilter()
        selectedSortOption = .dateDescending
        
        saveFilter(LaunchFilter())
        saveSortOption(.dateDescending)
        
        resetPagination()
        await loadLaunches(forceRefresh: false)
    }
    
    func changeSortOption(_ sortOption: LaunchSortOption) async {
        selectedSortOption = sortOption
        saveSortOption(sortOption)
        resetPagination()
        await loadLaunches(forceRefresh: false)
    }
    
    func cancelAllTasks() {
        loadTask?.cancel()
        loadMoreTask?.cancel()
        loadTask = nil
        loadMoreTask = nil
        isLoading = false
        isLoadingMore = false
    }
    
    // MARK: - Private Methods
    
    private func resetPagination() {
        currentPage = 1
        hasMorePages = true
        launches.removeAll()
    }
    
    private func loadMoreLaunches() async {
        guard canLoadMore else { return }
        
        let nextPage = currentPage + 1
        
        let task = Task {
            isLoadingMore = true
            currentError = nil
            
            do {
                try Task.checkCancellation()
                
                let result = try await launchRepository.getLaunches(
                    page: nextPage,
                    pageSize: pageSize,
                    sortOption: selectedSortOption,
                    filter: currentFilter,
                    forceRefresh: false
                )
                
                try Task.checkCancellation()
                
                launches.append(contentsOf: result.launches)
                currentPage = result.currentPage
                hasMorePages = result.hasNextPage
                
                // Memory management - prevent unlimited growth
                if launches.count > maxCachedLaunches {
                    let excess = launches.count - maxCachedLaunches
                    launches.removeFirst(excess)
                    SpaceXLogger.cacheOperation("🧹 Trimmed \(excess) old launches from memory")
                }
                
                await loadRocketNames()
                
            } catch is CancellationError {
                SpaceXLogger.network("🔄 Load more task was cancelled")
            } catch let appError as AppError {
                SpaceXLogger.error("❌ LaunchListViewModel caught AppError: \(appError)")
                currentError = appError
            } catch {
                SpaceXLogger.error("❌ LaunchListViewModel caught generic error: \(error)")
                SpaceXLogger.error("   Error type: \(type(of: error))")
                currentError = AppError.from(error)
                SpaceXLogger.error("   Mapped to AppError: \(String(describing: currentError))")
            }
            
            isLoadingMore = false
            loadMoreTask = nil
        }
        
        loadMoreTask = task
        await task.value
    }
    
    func getRocketName(for rocketId: String) -> String {
        return rocketNames[rocketId] ?? "Loading..."
    }
    
    func loadAvailableYears() async {
        do {
            let years = try await launchRepository.getAvailableYears()
            availableYears = years.sorted(by: >)
            SpaceXLogger.success("📅 Loaded \(years.count) available years")
        } catch {
            handleYearsLoadingError(error)
            availableYears = []
        }
    }
    
    private func handleYearsLoadingError(_ error: Error) {
        SpaceXLogger.error("❌ Failed to load available years: \(error)")
        
    #if DEBUG
        if let decodingError = error as? DecodingError {
            logDecodingError(decodingError)
        }
    #endif
    }
    
    #if DEBUG
    private func logDecodingError(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            SpaceXLogger.error("Data corrupted: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            SpaceXLogger.error("Key not found: \(key), \(context.debugDescription)")
        case .typeMismatch(let type, let context):
            SpaceXLogger.error("Type mismatch: \(type), \(context.debugDescription)")
        case .valueNotFound(let type, let context):
            SpaceXLogger.error("Value not found: \(type), \(context.debugDescription)")
        @unknown default:
            SpaceXLogger.error("Unknown decoding error")
        }
    }
    #endif
    
    private func loadRocketNames() async {
        let rocketIds = Set(launches.map(\.rocket))
        let missingRocketIds = rocketIds.subtracting(Set(rocketNames.keys))
        
        guard !missingRocketIds.isEmpty else { return }
        
        do {
            let names = try await rocketRepository.getRocketNames(for: Array(missingRocketIds))
            rocketNames.merge(names) { _, new in new }

            // Clean up old rocket names to prevent unlimited growth
            cleanupRocketNamesCache(currentRocketIds: rocketIds)

            SpaceXLogger.success("🚀 Loaded names for \(names.count) rockets")
        } catch {
            SpaceXLogger.error("❌ Failed to load rocket names: \(error)")
            // Set fallback names for missing rockets
            for rocketId in missingRocketIds where rocketNames[rocketId] == nil {
                rocketNames[rocketId] = "Unknown Rocket"
            }
        }
    }

    private func cleanupRocketNamesCache(currentRocketIds: Set<String>) {
        // Only clean up if we have too many cached names
        guard rocketNames.count > maxCachedRocketNames else { return }

        // Keep all rocket names for currently visible launches
        let visibleRocketIds = currentRocketIds

        // Remove rocket names not in current launches, keeping only the most recent
        let excessCount = rocketNames.count - maxCachedRocketNames
        if excessCount > 0 {
            let rocketNamesToRemove = rocketNames.keys
                .filter { !visibleRocketIds.contains($0) }
                .prefix(excessCount)

            for rocketId in rocketNamesToRemove {
                rocketNames.removeValue(forKey: rocketId)
            }

            SpaceXLogger.cacheOperation("🧹 Cleaned up \(rocketNamesToRemove.count) old rocket names, kept \(rocketNames.count)")
        }
    }

    // MARK: - Persistence
    
    private func restoreSortOption() -> LaunchSortOption {
        guard let rawValue = UserDefaults.standard.string(forKey: sortOptionKey),
              let sortOption = LaunchSortOption(rawValue: rawValue) else {
            SpaceXLogger.ui("📱 Using default sort option")
            return .dateDescending
        }
        SpaceXLogger.ui("📱 Restored sort option: \(sortOption)")
        return sortOption
    }
    
    private func saveSortOption(_ sortOption: LaunchSortOption) {
        UserDefaults.standard.set(sortOption.rawValue, forKey: sortOptionKey)
        SpaceXLogger.ui("💾 Sort option saved: \(sortOption)")
    }
    
    private func restoreFilter() -> LaunchFilter {
        guard let data = UserDefaults.standard.data(forKey: filterKey) else {
            SpaceXLogger.ui("📱 No saved filter found, using default")
            return LaunchFilter()
        }
        
        do {
            let filter = try JSONDecoder().decode(LaunchFilter.self, from: data)
            SpaceXLogger.ui("📱 Filter restored successfully")
            return filter
        } catch {
            SpaceXLogger.error("❌ Failed to restore filter: \(error)")
            return LaunchFilter()
        }
    }
    
    private func saveFilter(_ filter: LaunchFilter) {
        do {
            let data = try JSONEncoder().encode(filter)
            UserDefaults.standard.set(data, forKey: filterKey)
            SpaceXLogger.ui("💾 Filter saved successfully")
        } catch {
            SpaceXLogger.error("❌ Failed to save filter: \(error)")
        }
    }
}
