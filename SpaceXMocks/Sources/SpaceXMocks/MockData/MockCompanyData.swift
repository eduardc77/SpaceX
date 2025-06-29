import Foundation
import SpaceXDomain

public struct MockCompanyData {
    
    // MARK: - JSON Data
    
    public static let mockCompanyJSON = """
        {
            "name": "SpaceX",
            "founder": "Elon Musk", 
            "founded": 2002,
            "employees": 12000,
            "ceo": "Elon Musk",
            "valuation": 137000000000,
            "headquarters": {
                "address": "Rocket Road",
                "city": "Hawthorne",
                "state": "California"
            },
            "links": {
                "website": "https://www.spacex.com/",
                "flickr": "https://www.flickr.com/photos/spacex/",
                "twitter": "https://twitter.com/SpaceX",
                "elonTwitter": "https://twitter.com/elonmusk"
            },
            "summary": "SpaceX develops and manufactures space launch vehicles"
        }
        """.data(using: .utf8)!
    
    // MARK: - Mock Objects

    public static let spacex = Company(
        name: "SpaceX",
        founder: "Elon Musk",
        founded: 2002,
        employees: 12000,
        ceo: "Elon Musk",
        valuation: 137000000000,
        headquarters: Headquarters(
            address: "Rocket Road",
            city: "Hawthorne",
            state: "California"
        ),
        links: CompanyLinks(
            website: "https://www.spacex.com/",
            twitter: "https://twitter.com/SpaceX"
        ),
        summary: "SpaceX develops space vehicles"
    )
    
    /// Factory method for customizable company data
    public static func create(
        name: String = "SpaceX",
        founder: String = "Elon Musk",
        founded: Int = 2002,
        employees: Int = 12000,
        valuation: Int64 = 137000000000
    ) -> Company {
        return Company(
            name: name,
            founder: founder,
            founded: founded,
            employees: employees,
            ceo: founder,
            valuation: valuation,
            headquarters: Headquarters(
                address: "Rocket Road",
                city: "Hawthorne",
                state: "California"
            ),
            links: CompanyLinks(
                website: "https://www.\(name.lowercased()).com/",
                twitter: "https://twitter.com/\(name)"
            ),
            summary: "\(name) develops space vehicles"
        )
    }
}
