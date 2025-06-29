//
//  CompanyViewModel.swift
//  SpaceX
//
//  Created by User on 6/22/25.
//

import Observation
import SpaceXDomain
import SpaceXUtilities

@Observable
@MainActor
final class CompanyViewModel {
    var company: Company?
    var isLoading = true
    var currentError: AppError?
    
    @ObservationIgnored private let companyRepository: CompanyRepositoryProtocol
    @ObservationIgnored private var loadTask: Task<Void, Never>?
    
    var errorMessage: String? {
        currentError?.userMessage
    }
    
    init(companyRepository: CompanyRepositoryProtocol) {
        self.companyRepository = companyRepository
    }
    
    func loadCompany(forceRefresh: Bool = false) async {
        // Cancel any existing task
        if forceRefresh || loadTask != nil {
            loadTask?.cancel()
            loadTask = nil
        }
        
        // Don't start a new task if one is already running (unless forced)
        if !forceRefresh && loadTask != nil {
            return
        }
        
        // Clear error state when starting a retry
        if forceRefresh {
            currentError = nil
        }
        
        let task = Task {
            isLoading = true
            
            do {
                company = try await companyRepository.getCompany(forceRefresh: forceRefresh)
                currentError = nil // Clear any previous errors on success
                
            } catch is CancellationError {
                // Task was cancelled, don't update UI
                SpaceXLogger.network("🔄 Company load task was cancelled")
            } catch let appError as AppError {
                currentError = appError
                
                // Clear company data when error occurs
                if forceRefresh {
                    company = nil
                }
                SpaceXLogger.error("❌ Load company error: \(appError)")
            } catch {
                currentError = AppError.from(error)
                
                // Clear company data when error occurs
                if forceRefresh {
                    company = nil
                }
                SpaceXLogger.error("❌ Load company error: \(error)")
            }
            
            isLoading = false
            loadTask = nil
        }
        
        loadTask = task
        await task.value
    }
}
