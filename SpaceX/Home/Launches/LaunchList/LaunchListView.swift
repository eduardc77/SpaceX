//
//  LaunchListView.swift
//  SpaceX
//
//  Created by User on 6/21/25.
//

import SwiftUI
import SpaceXDomain

struct LaunchListView: View {
    let viewModel: LaunchListViewModel
    @Binding var selectedLaunch: Launch?
    
    var body: some View {
        Section {
            if viewModel.isLoading && viewModel.launches.isEmpty {
                loadingView
            } else if let error = viewModel.currentError, viewModel.launches.isEmpty {
                errorView(error)
            } else if viewModel.launches.isEmpty {
                emptyStateView
            } else {
                launchesView
            }
        } header: {
            headerView
                .listRowInsets(.init())
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var launchesView: some View {
        ForEach(viewModel.launches) { launch in
            Button {
                selectedLaunch = launch
            } label: {
                LaunchRowView(
                    launch: launch,
                    rocketName: viewModel.getRocketName(for: launch.rocket)
                )
                .contentShape(.rect)
            }
            .onAppear {
                // Load more when approaching the end
                if let index = viewModel.launches.firstIndex(where: { $0.id == launch.id }),
                   index >= viewModel.launches.count - 3 {
                    Task {
                        await viewModel.loadMoreIfNeeded(launch: launch)
                    }
                }
            }
        }
        
        // Loading more indicator
        if viewModel.isLoadingMore {
            HStack {
                Spacer()
                ProgressView()
                    .scaleEffect(0.8)
                Text("loading.more")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
    
    private var headerView: some View {
        Text("section.launches.title")
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.callout)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.leading)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.8))
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                Text("loading.launches")
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func errorView(_ error: AppError) -> some View {
        ContentUnavailableView {
            Label {
                Text("error.launches.title")
            } icon: {
                Image(systemName: error.iconName)
                    .foregroundColor(colorFromString(error.iconColor))
            }
        } description: {
            Text(error.userMessage)
        } actions: {
            Button {
                Task { @MainActor in
                    await viewModel.loadLaunches(forceRefresh: true)
                }
            } label: {
                Text(.actionRetry)
                    .fontWeight(.medium)
                    .padding(.horizontal, 4)
            }
            .buttonStyle(.bordered)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func colorFromString(_ colorString: String) -> Color {
        switch colorString {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "gray": return .gray
        default: return .orange
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label {
                Text("empty.launches")
            } icon: {
                Image(systemName: "airplane.departure")
                    .foregroundColor(.secondary)
            }
        } description: {
            Text("empty.launches.description")
        } actions: {
            Button("action.refresh") {
                Task { @MainActor in
                    await viewModel.loadLaunches(forceRefresh: true)
                }
            }
            .buttonStyle(.bordered)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
} 

#if DEBUG
import SpaceXMocks

#Preview {
    @Previewable @State var selectedLaunch: Launch? = MockLaunchData.successLaunch
    
    let mockRepos = createMockRepositories()
    let viewModel = LaunchListViewModel(
        launchRepository: mockRepos.launchRepository,
        rocketRepository: mockRepos.rocketRepository
    )
    
    // Pre-populate the ViewModel with mock data for preview
    viewModel.launches = Array(MockLaunchData.launches.prefix(10))
    viewModel.isLoading = false
    viewModel.availableYears = [2024, 2023, 2022, 2021, 2020]
    
    return ScrollView {
        LaunchListView(viewModel: viewModel, selectedLaunch: $selectedLaunch)
            .environment(HomeCoordinator())
    }
}
#endif
