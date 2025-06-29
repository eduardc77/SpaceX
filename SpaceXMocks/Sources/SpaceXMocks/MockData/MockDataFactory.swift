import Foundation
import SpaceXDomain

public struct MockDataFactory {

    public static func standardDataSet() -> (company: Company, rockets: [Rocket], launches: [Launch]) {
        return (
            company: MockCompanyData.spacex,
            rockets: MockRocketData.mockRockets,
            launches: Array(MockLaunchData.launches.prefix(10)) // First 10 for performance
        )
    }

    public static func smallDataSet() -> (company: Company, rockets: [Rocket], launches: [Launch]) {
        return (
            company: MockCompanyData.spacex,
            rockets: [MockRocketData.falcon9],
            launches: Array(MockLaunchData.launches.prefix(3))
        )
    }

    public static func fullDataSet() -> (company: Company, rockets: [Rocket], launches: [Launch]) {
        return (
            company: MockCompanyData.spacex,
            rockets: MockRocketData.mockRockets,
            launches: MockLaunchData.launches
        )
    }

    public static func errorScenarioData() -> (launches: [Launch], company: Company?) {
        let failureLaunches = MockLaunchData.launches.filter { $0.success == false }
        return (
            launches: failureLaunches,
            company: nil // Simulate company load failure
        )
    }

    public static func successOnlyData() -> (launches: [Launch], rockets: [Rocket]) {
        let successLaunches = MockLaunchData.launches.filter { $0.success == true }
        return (
            launches: successLaunches,
            rockets: MockRocketData.mockRockets
        )
    }

    public static func upcomingLaunchesData() -> [Launch] {
        return MockLaunchData.launches.filter { $0.upcoming == true }
    }
}
