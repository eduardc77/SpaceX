//
//  LaunchFilterSortViewModel.swift
//  SpaceX
//
//  Created by User on 6/29/25.
//

import Observation
import SpaceXDomain

@Observable
final class LaunchFilterSortViewModel {
    var selectedYears: Set<Int>
    var selectedSuccessStatus: SuccessFilter
    var selectedSortOption: LaunchSortOption
    
    private let initialFilter: LaunchFilter
    private let initialSortOption: LaunchSortOption
    
    var hasChanges: Bool {
        selectedYears != initialFilter.years || 
        selectedSuccessStatus != initialFilter.successStatus ||
        selectedSortOption != initialSortOption
    }
    
    var canClearAll: Bool {
        !selectedYears.isEmpty || 
        selectedSuccessStatus != .all || 
        selectedSortOption != .dateDescending
    }
    
    init(currentFilter: LaunchFilter, currentSortOption: LaunchSortOption) {
        self.initialFilter = currentFilter
        self.initialSortOption = currentSortOption
        
        self.selectedYears = currentFilter.years
        self.selectedSuccessStatus = currentFilter.successStatus
        self.selectedSortOption = currentSortOption
    }
    
    func toggleYear(_ year: Int) {
        if selectedYears.contains(year) {
            selectedYears.remove(year)
        } else {
            selectedYears.insert(year)
        }
    }
    
    func clearAll() {
        selectedYears.removeAll()
        selectedSuccessStatus = .all
        selectedSortOption = .dateDescending
    }
    
    func createUpdatedFilter() -> LaunchFilter {
        LaunchFilter(
            years: selectedYears,
            successStatus: selectedSuccessStatus
        )
    }
}
