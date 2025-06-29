//
//  LaunchFilterSortView.swift
//  SpaceX
//
//  Created by User on 6/22/25.
//

import SwiftUI
import SpaceXDomain

struct LaunchFilterSortView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: LaunchFilterSortViewModel
    
    private let availableYears: [Int]
    private let onApplyFilter: (LaunchFilter, LaunchSortOption) -> Void
    
    init(
        availableYears: [Int],
        currentFilter: LaunchFilter,
        currentSortOption: LaunchSortOption,
        onApplyFilter: @escaping (LaunchFilter, LaunchSortOption) -> Void
    ) {
        self.availableYears = availableYears
        self.onApplyFilter = onApplyFilter
        self._viewModel = State(initialValue: LaunchFilterSortViewModel(
            currentFilter: currentFilter,
            currentSortOption: currentSortOption
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                yearFilterSection
                successFilterSection
                sortOptionsSection
            }
            .listSectionSpacing(6)
            .navigationTitle("filter.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    cancelButton
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    confirmationButtons
                }
            }
        }
    }
    
    func applyChanges() {
        let newFilter = viewModel.createUpdatedFilter()
        onApplyFilter(newFilter, viewModel.selectedSortOption)
        dismiss()
    }
}

// MARK: - Subviews

private extension LaunchFilterSortView {
    var yearFilterSection: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(availableYears, id: \.self) { year in
                    YearToggleButton(
                        year: year,
                        isSelected: viewModel.selectedYears.contains(year)
                    ) {
                        viewModel.toggleYear(year)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Label("filter.year.title", systemImage: "calendar")
        }
    }
    
    var successFilterSection: some View {
        Section {
            SuccessFilterPicker(
                selectedStatus: $viewModel.selectedSuccessStatus
            )
        } header: {
            Label("filter.success.title", systemImage: "checkmark")
        }
    }
    
    var sortOptionsSection: some View {
        Section {
            SortOptionPicker(
                selectedOption: $viewModel.selectedSortOption
            )
        } header: {
            Label("filter.sort.title", systemImage: "arrow.up.arrow.down")
        }
    }
    
    var cancelButton: some View {
        Button(String(localized: "action.cancel")) {
            dismiss()
        }
    }
    
    var confirmationButtons: some View {
        HStack {
            if viewModel.canClearAll {
                Button(String(localized: "action.clear")) {
                    viewModel.clearAll()
                }
                .foregroundColor(.red)
                .fontWeight(.regular)
            }
            
            Button(String(localized: "action.apply")) {
                applyChanges()
            }
            .fontWeight(.semibold)
            .disabled(!viewModel.hasChanges)
        }
    }
}

#Preview {
    LaunchFilterSortView(
        availableYears: [2008, 2020, 2022, 2023, 2024, 2025],
        currentFilter: LaunchFilter(years: [2023, 2024], successStatus: .successful),
        currentSortOption: .dateDescending
    ) { _, _ in }
} 
