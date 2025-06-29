//
//  HomeCoordinator.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain
import SpaceXUtilities

@Observable
class HomeCoordinator {
    var navigationPath = NavigationPath()
    
    enum Destination: Hashable {
        case missionInfo(url: URL)
        case wikipediaArticle(url: URL)
        case newsArticle(url: URL)
        case spacexWebsite(url: URL)
    }
    
    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }
    
    func navigateBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    // Helpers
    
    func showWikipedia(for launch: Launch) {
        guard let wikipediaURLString = launch.links.wikipedia,
              let wikipediaURL = URL(string: wikipediaURLString) else {
            SpaceXLogger.error("❌ No Wikipedia link available for \(launch.name)")
            return
        }
        SpaceXLogger.network("🔍 Navigating to Wikipedia: \(wikipediaURL)")
        navigate(to: .wikipediaArticle(url: wikipediaURL))
    }
    
    func showWebcast(for launch: Launch) {
        guard let webcastURLString = launch.links.webcast,
              let webcastURL = URL(string: webcastURLString) else {
            SpaceXLogger.error("❌ No webcast link available for \(launch.name)")
            return
        }
        SpaceXLogger.network("🔍 Navigating to Webcast: \(webcastURL)")
        navigate(to: .missionInfo(url: webcastURL))
    }
    
    func showArticle(for launch: Launch) {
        guard let articleURLString = launch.links.article,
              let articleURL = URL(string: articleURLString) else {
            SpaceXLogger.error("❌ No article link available for \(launch.name)")
            return
        }
        SpaceXLogger.network("🔍 Navigating to Article: \(articleURL)")
        navigate(to: .newsArticle(url: articleURL))
    }
    
    func showSpaceXWebsite(websiteURL: String? = nil) {
        // Use provided URL or fallback to hardcoded
        let urlString = websiteURL ?? "https://www.spacex.com"
        guard let url = URL(string: urlString) else {
            SpaceXLogger.error("❌ Invalid URL: \(urlString)")
            return
        }
        SpaceXLogger.network("🔍 Navigating to SpaceX Website: \(url)")
        navigate(to: .spacexWebsite(url: url))
    }
    
    // MARK: - URL Helpers
    
    private func createSpaceXMissionURL(for launch: Launch) -> URL? {
        // Create a search URL for the mission
        let baseURL = "https://www.spacex.com/missions"
        return URL(string: baseURL)
    }
}
