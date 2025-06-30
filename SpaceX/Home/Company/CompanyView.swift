//
//  CompanyView.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain

struct CompanyView: View {
    let viewModel: CompanyViewModel
    
    init(viewModel: CompanyViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 0) {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.currentError {
                    errorView(error)
                } else if let company = viewModel.company {
                    companyContentView(company)
                } else {
                    emptyStateView
                }
            }
        } header: {
            headerView
        }
        .listRowInsets(.init())
        .listRowSeparator(.hidden)
        .frame(maxWidth: .infinity)
        
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        Text(.sectionCompanyTitle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.callout)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.leading)
            .padding(.vertical, 2)
            .background(Color.blue.opacity(0.8))
    }
    
    private func companyContentView(_ company: Company) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(company.formattedDescription)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
        }
    }
    
    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text(.loadingCompany)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 20)
    }

    private func errorView(_ error: AppError) -> some View {
        ContentUnavailableView {
            Label {
                Text(.errorCompanyTitle)
            } icon: {
                Image(systemName: error.iconName)
                    .foregroundColor(colorFromString(error.iconColor))
            }
        } description: {
            Text(error.userMessage)
        } actions: {
            Button {
                Task { @MainActor in
                    await viewModel.loadCompany(forceRefresh: true)
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
        VStack(spacing: 8) {
            Image(systemName: "building.2")
                .foregroundColor(.secondary)
                .font(.title2)
            
            Text("empty.company")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#if DEBUG
import SpaceXMocks

#Preview {
    let mockRepos = createMockRepositories()
    let viewModel = CompanyViewModel(companyRepository: mockRepos.companyRepository)
    
    // Pre-populate the ViewModel with mock data for preview
    viewModel.company = MockCompanyData.spacex
    viewModel.isLoading = false
    
    return CompanyView(viewModel: viewModel)
}
#endif
