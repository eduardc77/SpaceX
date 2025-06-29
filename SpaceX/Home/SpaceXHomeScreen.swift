//
//  SpaceXHomeScreen.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain

struct SpaceXHomeScreen: View {
    @Environment(HomeCoordinator.self) private var coordinator
    
    // ViewModels managed at the container level
    @State private var launchesViewModel: LaunchListViewModel
    @State private var companyViewModel: CompanyViewModel
    
    @State private var isRefreshing = false
    @State private var showingFilterView = false
    @State private var selectedLaunch: Launch?
    @State private var isInitialLoad = true
    @State private var isRepositoriesInitialized = false
    
    private var bindableCoordinator: Bindable<HomeCoordinator> {
        Bindable(coordinator)
    }
    
    init(repositories: SpaceXRepositories) {
        self._launchesViewModel = State(initialValue: LaunchListViewModel(
            launchRepository: repositories.launchRepository,
            rocketRepository: repositories.rocketRepository
        ))
        
        self._companyViewModel = State(initialValue: CompanyViewModel(
            companyRepository: repositories.companyRepository
        ))
    }
    
    var body: some View {
        NavigationStack(path: bindableCoordinator.navigationPath) {
            List {
                CompanyView(viewModel: companyViewModel)
                LaunchListView(viewModel: launchesViewModel, selectedLaunch: $selectedLaunch)
            }
            .listSectionSpacing(0)
            .listStyle(.plain)
            .task {
                if isInitialLoad {
                    await loadInitialData()
                    isInitialLoad = false
                }
            }
            .refreshable {
                await refreshAll()
            }
            .toolbarTitleDisplayMode(.inline)
            .navigationTitle("app.title")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    filterButton
                }
            }
            .sheet(isPresented: $showingFilterView) {
                LaunchFilterSortView(
                    availableYears: launchesViewModel.availableYears,
                    currentFilter: launchesViewModel.currentFilter,
                    currentSortOption: launchesViewModel.selectedSortOption
                ) { newFilter, newSortOption in
                    Task { @MainActor in
                        await launchesViewModel.applyFilterAndSort(filter: newFilter, sortOption: newSortOption)
                    }
                }
            }
            .sheet(item: $selectedLaunch) { launch in
                LaunchDetailSheetView(launch: launch)
            }
            .navigationDestination(for: HomeCoordinator.Destination.self) { destination in
                navigationDestinationView(for: destination)
            }
            .errorAlert($launchesViewModel.currentError)
        }
        .withNetworkStatusBanner()
    }
    
    private func loadInitialData() async {
        async let launchesLoad: Void = launchesViewModel.loadLaunches(forceRefresh: false)
        async let companyLoad: Void = companyViewModel.loadCompany(forceRefresh: false)
        _ = await (launchesLoad, companyLoad)
    }
    
    private func refreshAll() async {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        defer { isRefreshing = false }
        
        async let launchesRefresh: Void = launchesViewModel.loadLaunches(forceRefresh: true)
        async let companyRefresh: Void = companyViewModel.loadCompany(forceRefresh: true)
        _ = await (launchesRefresh, companyRefresh)
    }
    
    @ViewBuilder
    private func navigationDestinationView(for destination: HomeCoordinator.Destination) -> some View {
        switch destination {
        case .missionInfo(let url):
            LaunchDetailWebView(url: url, title: LocalizedStringKey("external.webcast"))
            
        case .wikipediaArticle(let url):
            LaunchDetailWebView(url: url, title: "external.wikipedia")
            
        case .newsArticle(let url):
            LaunchDetailWebView(url: url, title: "external.news_article")
            
        case .spacexWebsite(let url):
            LaunchDetailWebView(url: url, title: "app.title")
        }
    }
    
    private var filterButton: some View {
        Button {
            showingFilterView = true
        } label: {
            Image(systemName: launchesViewModel.currentFilter.isActive ?
                  "line.3.horizontal.decrease.circle.fill" :
                    "line.3.horizontal.decrease.circle"
            )
            .foregroundColor(launchesViewModel.currentFilter.isActive ? .blue : .primary)
        }
    }
}

#if DEBUG
import SpaceXMocks
import SpaceXUtilities

#Preview {
    let repositories = createMockRepositories()
    
    SpaceXHomeScreen(repositories: repositories)
        .environment(HomeCoordinator())
        .environment(NetworkMonitor())
}
#endif
