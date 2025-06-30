//
//  LocalizedStringKey+App.swift
//  SpaceX
//
//  Created by User on 6/27/25.
//

import SwiftUI

public extension LocalizedStringKey {
    
    // MARK: - App & Navigation
    static var appTitle: LocalizedStringKey { "app.title" }
    
    // MARK: - Common Actions
    static var actionCancel: LocalizedStringKey { "action.cancel" }
    static var actionDone: LocalizedStringKey { "action.done" }
    static var actionApply: LocalizedStringKey { "action.apply" }
    static var actionClear: LocalizedStringKey { "action.clear" }
    static var actionRefresh: LocalizedStringKey { "action.refresh" }
    static var actionRetry: LocalizedStringKey { "action.retry" }
    
    // MARK: - Sections
    static var sectionCompanyTitle: LocalizedStringKey { "section.company.title" }
    static var sectionLaunchesTitle: LocalizedStringKey { "section.launches.title" }
    
    // MARK: - Loading States
    static var loadingApp: LocalizedStringKey { "loading.app" }
    static var loadingCompany: LocalizedStringKey { "loading.company" }
    static var loadingLaunches: LocalizedStringKey { "loading.launches" }
    static var loadingMore: LocalizedStringKey { "loading.more" }
    
    // MARK: - Error Messages
    static var errorAppInitTitle: LocalizedStringKey { "error.app_init.title" }
    static var errorCompanyTitle: LocalizedStringKey { "error.company.title" }
    static var errorLaunchesTitle: LocalizedStringKey { "error.launches.title" }
    
    // MARK: - Empty States
    static var emptyCompany: LocalizedStringKey { "empty.company" }
    static var emptyLaunches: LocalizedStringKey { "empty.launches" }
    static var emptyLaunchesDescription: LocalizedStringKey { "empty.launches.description" }
    
    // MARK: - Status (UI)
    static var statusUpcoming: LocalizedStringKey { "status.upcoming" }
    static var statusSuccess: LocalizedStringKey { "status.success" }
    static var statusFailure: LocalizedStringKey { "status.failure" }
    static var statusUnknown: LocalizedStringKey { "status.unknown" }
    static var statusSuccessful: LocalizedStringKey { "status.successful" }
    static var statusFailed: LocalizedStringKey { "status.failed" }
    
    // MARK: - Filter & Sort (UI)
    static var filterTitle: LocalizedStringKey { "filter.title" }
    static var filterYearTitle: LocalizedStringKey { "filter.year.title" }
    static var filterSuccessTitle: LocalizedStringKey { "filter.success.title" }
    static var filterSortTitle: LocalizedStringKey { "filter.sort.title" }
    
    // MARK: - Launch Details
    static var launchMissionStatus: LocalizedStringKey { "launch.mission_status" }
    static var launchMissionDetails: LocalizedStringKey { "launch.mission_details" }
    static var launchLearnMore: LocalizedStringKey { "launch.learn_more" }
    static var launchReadArticle: LocalizedStringKey { "launch.read_article" }
    static var launchViewWikipedia: LocalizedStringKey { "launch.view_wikipedia" }
    static var launchVisitWebsite: LocalizedStringKey { "launch.visit_website" }
    static var launchWatchWebcast: LocalizedStringKey { "launch.watch_webcast" }
    
    // MARK: - External Links
    static var externalWikipedia: LocalizedStringKey { "external.wikipedia" }
    static var externalNewsArticle: LocalizedStringKey { "external.news_article" }
    
    // MARK: - Date & Time
    static var datePending: LocalizedStringKey { "date.pending" }
    static var dateToday: LocalizedStringKey { "date.today" }
    
    // MARK: - Tab Bar
    static var tabHome: LocalizedStringKey { "tab.home" }
    static var tabSettings: LocalizedStringKey { "tab.settings" }
    
    // MARK: - Settings
    static var settingsTitle: LocalizedStringKey { "settings.title" }
    static var settingsAppearanceHeader: LocalizedStringKey { "settings.appearance.header" }
    static var settingsAppearanceFooter: LocalizedStringKey { "settings.appearance.footer" }
    static var settingsDarkMode: LocalizedStringKey { "settings.dark_mode" }
    static var settingsDarkModeDescription: LocalizedStringKey { "settings.dark_mode.description" }
    static var settingsAboutHeader: LocalizedStringKey { "settings.about.header" }
    static var settingsVersion: LocalizedStringKey { "settings.version" }
    
    // MARK: - Dynamic String Helpers (Main Bundle)
    static func launchFlightNumber(_ number: Int) -> String {
        String(format: String(localized: "launch.flight_number"), number)
    }
    
    static func launchRocketLabel(_ rocketName: String) -> String {
        String(format: String(localized: "launch.rocket_label"), rocketName)
    }
    
    static func dateDaysFromNow(_ days: Int) -> String {
        String(format: String(localized: "date.days_from_now"), days)
    }
    
    static func dateDaysSinceNow(_ days: Int) -> String {
        String(format: String(localized: "date.days_since_now"), days)
    }
}
