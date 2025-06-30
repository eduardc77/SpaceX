//
//  SpaceXApp.swift
//  SpaceX
//
//  Created by User on 6/20/25.
//

import SwiftUI
import SwiftData
import SpaceXData
import SpaceXDomain
import SpaceXUtilities
import Kingfisher

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return true
    }
}

@main
struct SpaceXApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var modelContainer: ModelContainer?
    @State private var repositories: SpaceXRepositories?
    @State private var errorMessage: String?
    @State private var coordinator = HomeCoordinator()
    @State private var networkMonitor = NetworkMonitor()

    init() {
        configureKingfisher()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = modelContainer, let repos = repositories {
                    ContentView()
                        .modelContainer(container)
                        .environment(coordinator)
                        .environment(networkMonitor)
                        .environment(repos)
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label(.errorAppInitTitle, systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button(.actionTryAgain, action: createModelContainer)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ProgressView(.loadingApp)
                        .onAppear(perform: createModelContainer)
                }
            }
        }
    }

    private func createModelContainer() {
        do {
            let container = try createSpaceXModelContainer()
            self.modelContainer = container

            // Create repositories after model container is ready
            Task { @MainActor in
                let modelContext = ModelContext(container)
                self.repositories = createSpaceXRepositories(
                    modelContext: modelContext,
                    networkMonitor: networkMonitor
                )
            }

            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to create model container: \(error.localizedDescription)"
        }
    }

    private func configureKingfisher() {
        let cache = ImageCache.default

        // Memory cache: 50MB, max 100 images, expires in 5 minutes
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        cache.memoryStorage.config.countLimit = 100
        cache.memoryStorage.config.expiration = .seconds(300) // 5 minutes

        // Disk cache: 100MB, expires in 7 days
        cache.diskStorage.config.sizeLimit = 100 * 1024 * 1024
        cache.diskStorage.config.expiration = .days(7)

        let downloader = ImageDownloader.default
        downloader.sessionConfiguration.timeoutIntervalForRequest = 15.0
        downloader.sessionConfiguration.timeoutIntervalForResource = 30.0

        downloader.sessionConfiguration.waitsForConnectivity = true
        downloader.sessionConfiguration.httpMaximumConnectionsPerHost = 2
    }
}
