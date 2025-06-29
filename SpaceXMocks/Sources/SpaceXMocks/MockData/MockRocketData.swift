import Foundation
import SpaceXDomain

public struct MockRocketData {
    
    // MARK: - JSON Data
    public static let mockRocketsJSON = """
        [
            {
                "id": "rocket1",
                "name": "Falcon 9",
                "description": "Falcon 9 is a reusable, two-stage rocket",
                "active": true,
                "costPerLaunch": 62000000,
                "successRatePct": 97,
                "flickrImages": ["https://farm5.staticflickr.com/4599/38583829295_581f34dd84_b.jpg"],
                "wikipedia": "https://en.wikipedia.org/wiki/Falcon_9"
            },
            {
                "id": "rocket2", 
                "name": "Falcon Heavy",
                "description": "Heavy-lift version of Falcon 9",
                "active": true,
                "costPerLaunch": 90000000,
                "successRatePct": 100,
                "flickrImages": ["https://farm5.staticflickr.com/4645/40126461851_b15cd9829f_b.jpg"],
                "wikipedia": "https://en.wikipedia.org/wiki/Falcon_Heavy"
            }
        ]
        """.data(using: .utf8)!
    
    public static let mockRocketJSON = """
        {
            "id": "rocket1",
            "name": "Falcon 9",
            "description": "Falcon 9 is a reusable, two-stage rocket",
            "active": true,
            "costPerLaunch": 62000000,
            "successRatePct": 97,
            "flickrImages": ["https://farm5.staticflickr.com/4599/38583829295_581f34dd84_b.jpg"],
            "wikipedia": "https://en.wikipedia.org/wiki/Falcon_9"
        }
        """.data(using: .utf8)!
    
    // MARK: - Mock Objects
    public static let falcon9 = Rocket(
        id: "5e9d0d95eda69973a809d1ec",
        name: "Falcon 9",
        description: "Falcon 9 is a reusable, two-stage rocket designed and manufactured by SpaceX.",
        active: true,
        costPerLaunch: 62000000,
        successRatePct: 97,
        flickrImages: [
            "https://farm1.staticflickr.com/929/28787338307_3453a11a77_b.jpg",
            "https://farm4.staticflickr.com/3955/32915197674_eee74d81bb_b.jpg"
        ],
        wikipedia: "https://en.wikipedia.org/wiki/Falcon_9"
    )

    public static let falconHeavy = Rocket(
        id: "5e9d0d95eda69955f709d1eb",
        name: "Falcon Heavy",
        description: "Falcon Heavy is a reusable super heavy-lift launch vehicle designed and manufactured by SpaceX.",
        active: true,
        costPerLaunch: 90000000,
        successRatePct: 100,
        flickrImages: [
            "https://farm5.staticflickr.com/4599/38583829295_581f34dd84_b.jpg",
            "https://farm5.staticflickr.com/4645/38583830575_3f0f7215e6_b.jpg"
        ],
        wikipedia: "https://en.wikipedia.org/wiki/Falcon_Heavy"
    )

    public static let mockRockets = [falcon9, falconHeavy]
    
    /// Factory method for customizable rocket data
    public static func create(
        id: String = "custom_rocket",
        name: String = "Custom Rocket",
        description: String? = nil,
        active: Bool = true,
        costPerLaunch: Int = 50000000,
        successRatePct: Int = 95
    ) -> Rocket {
        return Rocket(
            id: id,
            name: name,
            description: description ?? "\(name) is a rocket designed for space missions.",
            active: active,
            costPerLaunch: costPerLaunch,
            successRatePct: successRatePct,
            flickrImages: ["https://example.com/\(id).jpg"],
            wikipedia: "https://en.wikipedia.org/wiki/\(name.replacingOccurrences(of: " ", with: "_"))"
        )
    }
}
