//
//  MockLaunchData.swift
//  SpaceXUtilities
//
//  Created by User on 6/21/25.
//

import Foundation
import SpaceXDomain

public struct MockLaunchData {
    
    // MARK: - JSON Data

    public static let mockLaunchJSON = """
        {
            "id": "5eb87d42ffd86e000604b384",
            "name": "Falcon Heavy Test Flight",
            "details": "The Falcon Heavy test flight was the first attempt by SpaceX to launch its Falcon Heavy rocket.",
            "upcoming": false,
            "success": true,
            "date_utc": "2024-02-06T20:45:00.000Z",
            "date_unix": 1707251100,
            "links": {
                "patch": {
                    "small": "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    "large": "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                },
                "webcast": "https://youtu.be/wbSwFU6tY1c",
                "wikipedia": "https://en.wikipedia.org/wiki/Falcon_Heavy_test_flight"
            },
            "rocket": "5e9d0d95eda69973a809d1ec",
            "flight_number": 64,
            "cores": []
        }
        """.data(using: .utf8)!
    
    public static let mockPaginatedLaunchesJSON = """
        {
            "docs": [
                {
                    "id": "5eb87d42ffd86e000604b384",
                    "name": "Falcon Heavy Test Flight",
                    "details": "The Falcon Heavy test flight was the first attempt by SpaceX to launch its Falcon Heavy rocket.",
                    "upcoming": false,
                    "success": true,
                    "date_utc": "2024-02-06T20:45:00.000Z",
                    "date_unix": 1707251100,
                    "links": {
                        "patch": {
                            "small": "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                            "large": "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                        },
                        "webcast": "https://youtu.be/wbSwFU6tY1c",
                        "wikipedia": "https://en.wikipedia.org/wiki/Falcon_Heavy_test_flight"
                    },
                    "rocket": "5e9d0d95eda69973a809d1ec",
                    "flight_number": 64,
                    "cores": []
                },
                {
                    "id": "5eb87d47ffd86e000604b38c",
                    "name": "Arabsat-6A",
                    "details": "SpaceX's Falcon Heavy rocket will launch the Arabsat-6A communications satellite.",
                    "upcoming": false,
                    "success": true,
                    "date_utc": "2023-04-11T22:35:00.000Z",
                    "date_unix": 1681254900,
                    "links": {
                        "patch": {
                            "small": "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                            "large": "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                        },
                        "webcast": "https://youtu.be/-B_tWbjFIGI",
                        "wikipedia": "https://en.wikipedia.org/wiki/Arabsat-6A"
                    },
                    "rocket": "5e9d0d95eda69973a809d1ec",
                    "flight_number": 69,
                    "cores": []
                }
            ],
            "totalDocs": 200,
            "limit": 20,
            "totalPages": 10,
            "page": 1,
            "pagingCounter": 1,
            "hasPrevPage": false,
            "hasNextPage": true,
            "prevPage": null,
            "nextPage": 2
        }
        """.data(using: .utf8)!
    
    public static let mockYearsJSON = """
        {
            "docs": [
                {"dateUtc": "2024-01-15T10:30:00.000Z", "id": "1"},
                {"dateUtc": "2023-05-20T14:15:00.000Z", "id": "2"},
                {"dateUtc": "2022-12-10T08:45:00.000Z", "id": "3"}
            ]
        }
        """.data(using: .utf8)!
    
    // MARK: - Mock Objects
    
    public static let launches: [Launch] = [
        Launch(
            id: "5eb87d42ffd86e000604b384",
            name: "Falcon Heavy Test Flight",
            details: "The Falcon Heavy test flight was the first attempt by SpaceX to launch its Falcon Heavy rocket.",
            upcoming: false,
            success: true,
            dateUtc: "2024-02-06T20:45:00.000Z",
            dateUnix: 1707251100,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: "https://youtu.be/wbSwFU6tY1c",
                wikipedia: "https://en.wikipedia.org/wiki/Falcon_Heavy_test_flight"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 64,
            cores: []
        ),

        Launch(
            id: "5eb87d47ffd86e000604b38c",
            name: "Arabsat-6A",
            details: "SpaceX's Falcon Heavy rocket will launch the Arabsat-6A communications satellite.",
            upcoming: false,
            success: true,
            dateUtc: "2023-04-11T22:35:00.000Z",
            dateUnix: 1681254900,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                    large: "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                ),
                webcast: "https://youtu.be/-B_tWbjFIGI",
                wikipedia: "https://en.wikipedia.org/wiki/Arabsat-6A"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 69,
            cores: []
        ),

        Launch(
            id: "starship_success_1",
            name: "Starship IFT-4",
            details: "Fourth integrated flight test of Starship and Super Heavy achieved multiple milestones.",
            upcoming: false,
            success: true,
            dateUtc: "2024-06-06T12:50:00.000Z",
            dateUnix: 1717676200,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: "https://youtu.be/L7tK_S4_LQU",
                wikipedia: nil
            ),
            rocket: "5e9d0d96eda699382d09d1ee",
            flightNumber: 398,
            cores: []
        ),

        Launch(
            id: "5eb87cd9ffd86e000604b32a",
            name: "FalconSat",
            details: "Engine failure at 33 seconds and loss of vehicle",
            upcoming: false,
            success: false,
            dateUtc: "2006-03-24T22:30:00.000Z",
            dateUnix: 1143239400,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/94/f2/NN6Ph45r_o.png",
                    large: "https://images2.imgbox.com/5b/02/QcxHUb5V_o.png"
                ),
                webcast: nil,
                wikipedia: "https://en.wikipedia.org/wiki/DemoSat"
            ),
            rocket: "5e9d0d95eda69955f7f4c6a8",
            flightNumber: 1,
            cores: []
        ),

        Launch(
            id: "starship_failure_1",
            name: "Starship IFT-1",
            details: "First integrated flight test ended in rapid unscheduled disassembly during ascent.",
            upcoming: false,
            success: false,
            dateUtc: "2023-04-20T14:00:00.000Z",
            dateUnix: 1682002800,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: "https://youtu.be/L1cHk5D0j5A",
                wikipedia: nil
            ),
            rocket: "5e9d0d96eda699382d09d1ee",
            flightNumber: 395,
            cores: []
        ),

        Launch(
            id: "future123",
            name: "Starship IFT-6",
            details: "Sixth integrated flight test of Starship and Super Heavy.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-03-15T14:30:00.000Z",
            dateUnix: 1741870200,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d96eda699382d09d1ee",
            flightNumber: 400,
            cores: []
        ),

        Launch(
            id: "future124",
            name: "Europa Clipper Mission",
            details: "Mission to study Jupiter's moon Europa and its subsurface ocean.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-08-10T16:00:00.000Z",
            dateUnix: 1754820000,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 401,
            cores: []
        ),

        Launch(
            id: "falcon9_2022_01",
            name: "Transporter-3",
            details: "SpaceX's third dedicated smallsat rideshare mission.",
            upcoming: false,
            success: true,
            dateUtc: "2022-01-13T15:25:00.000Z",
            dateUnix: 1642086300,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/3d/86/cnu0pan8_o.png",
                    large: "https://images2.imgbox.com/40/e3/GypSkayF_o.png"
                ),
                webcast: "https://youtu.be/SWuMIWlHk2s",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 135,
            cores: []
        ),

        Launch(
            id: "falcon9_2022_02",
            name: "NROL-87",
            details: "Classified mission for the National Reconnaissance Office.",
            upcoming: false,
            success: true,
            dateUtc: "2022-02-02T20:18:00.000Z",
            dateUnix: 1643834280,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 136,
            cores: []
        ),

        Launch(
            id: "falcon9_2022_03",
            name: "Starlink 4-7",
            details: "SpaceX Starlink internet constellation mission.",
            upcoming: false,
            success: true,
            dateUtc: "2022-02-21T14:44:00.000Z",
            dateUnix: 1645453440,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/1c/f8/nSiaIaJN_o.png",
                    large: "https://images2.imgbox.com/40/e3/dQjxiPTJ_o.png"
                ),
                webcast: "https://youtu.be/jTMJK7wb0rM",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 137,
            cores: []
        ),

        Launch(
            id: "falcon9_2021_01",
            name: "Crew-2",
            details: "SpaceX Crew Dragon's second operational crewed mission to the ISS.",
            upcoming: false,
            success: true,
            dateUtc: "2021-04-23T09:49:00.000Z",
            dateUnix: 1619172540,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: "https://youtu.be/xY96v0OIcK4",
                wikipedia: "https://en.wikipedia.org/wiki/SpaceX_Crew-2"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 123,
            cores: []
        ),

        Launch(
            id: "falcon9_2021_02",
            name: "Starlink 1-15",
            details: "SpaceX Starlink internet constellation mission.",
            upcoming: false,
            success: true,
            dateUtc: "2021-05-09T06:42:00.000Z",
            dateUnix: 1620539320,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/1c/f8/nSiaIaJN_o.png",
                    large: "https://images2.imgbox.com/40/e3/dQjxiPTJ_o.png"
                ),
                webcast: "https://youtu.be/JuUd_stZIDM",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 124,
            cores: []
        ),

        Launch(
            id: "falcon9_2021_03",
            name: "SXM-8",
            details: "SiriusXM-8 satellite for SiriusXM radio services.",
            upcoming: false,
            success: true,
            dateUtc: "2021-06-06T04:26:00.000Z",
            dateUnix: 1622952360,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: "https://youtu.be/za7nfOh_Ov8",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 125,
            cores: []
        ),

        Launch(
            id: "falcon9_2020_01",
            name: "Demo-2",
            details: "SpaceX's first crewed mission to the International Space Station.",
            upcoming: false,
            success: true,
            dateUtc: "2020-05-30T19:22:00.000Z",
            dateUnix: 1590868920,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: "https://youtu.be/xY96v0OIcK4",
                wikipedia: "https://en.wikipedia.org/wiki/Crew_Dragon_Demo-2"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 95,
            cores: []
        ),

        Launch(
            id: "falcon9_2020_02",
            name: "GPS III SV03",
            details: "Third GPS III satellite for the U.S. Space Force.",
            upcoming: false,
            success: true,
            dateUtc: "2020-06-30T20:10:00.000Z",
            dateUnix: 1593546600,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: "https://youtu.be/KU6KogxG5BE",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 96,
            cores: []
        ),

        Launch(
            id: "falcon9_2019_01",
            name: "CRS-16",
            details: "SpaceX's sixteenth Commercial Resupply Services mission to the ISS.",
            upcoming: false,
            success: true,
            dateUtc: "2019-12-05T17:29:00.000Z",
            dateUnix: 1575566940,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                    large: "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                ),
                webcast: "https://youtu.be/2ZL0tbOZYhE",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 81,
            cores: []
        ),

        Launch(
            id: "falcon9_2019_02",
            name: "JCSat-18/Kacific1",
            details: "Joint mission carrying both JCSat-18 and Kacific1 satellites.",
            upcoming: false,
            success: true,
            dateUtc: "2019-12-16T23:10:00.000Z",
            dateUnix: 1576535400,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: "https://youtu.be/VnvHWO6AkLs",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 82,
            cores: []
        ),

        Launch(
            id: "falcon9_2018_01",
            name: "Bangabandhu-1",
            details: "Bangladesh's first geostationary communications satellite.",
            upcoming: false,
            success: true,
            dateUtc: "2018-05-11T20:14:00.000Z",
            dateUnix: 1526070840,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                    large: "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                ),
                webcast: "https://youtu.be/fZh6A3NbBvE",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 54,
            cores: []
        ),

        Launch(
            id: "falcon9_2018_02",
            name: "Iridium NEXT 6",
            details: "Sixth batch of Iridium NEXT satellites.",
            upcoming: false,
            success: true,
            dateUtc: "2018-05-22T19:47:00.000Z",
            dateUnix: 1527021120,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/1c/f8/nSiaIaJN_o.png",
                    large: "https://images2.imgbox.com/40/e3/dQjxiPTJ_o.png"
                ),
                webcast: "https://youtu.be/y4xBFHjkUvw",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 55,
            cores: []
        ),

        Launch(
            id: "falcon9_2015_failure",
            name: "CRS-7",
            details: "Mission failed due to launch vehicle failure approximately 2 minutes and 19 seconds after liftoff.",
            upcoming: false,
            success: false,
            dateUtc: "2015-06-28T14:21:00.000Z",
            dateUnix: 1435499260,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                    large: "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                ),
                webcast: "https://youtu.be/PuNymhcTtSQ",
                wikipedia: "https://en.wikipedia.org/wiki/SpaceX_CRS-7"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 19,
            cores: []
        ),

        Launch(
            id: "falcon9_2016_failure",
            name: "Amos-6",
            details: "Vehicle and payload lost during static fire test.",
            upcoming: false,
            success: false,
            dateUtc: "2016-09-01T13:07:00.000Z",
            dateUnix: 1472731620,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: nil,
                wikipedia: "https://en.wikipedia.org/wiki/Amos-6"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 29,
            cores: []
        ),

        Launch(
            id: "falcon9_2017_01",
            name: "EchoStar 23",
            details: "Communications satellite for EchoStar Corporation.",
            upcoming: false,
            success: true,
            dateUtc: "2017-03-16T06:00:00.000Z",
            dateUnix: 1489644000,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: "https://youtu.be/lZmqbL-hz7U",
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 36,
            cores: []
        ),

        Launch(
            id: "falcon9_2017_02",
            name: "SES-10",
            details: "First mission using a flight-proven Falcon 9 first stage.",
            upcoming: false,
            success: true,
            dateUtc: "2017-03-30T22:27:00.000Z",
            dateUnix: 1490916420,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/40/d2/t0VKPD7g_o.png",
                    large: "https://images2.imgbox.com/ab/b4/Hq6ElFvx_o.png"
                ),
                webcast: "https://youtu.be/giNhaEzv_PI",
                wikipedia: "https://en.wikipedia.org/wiki/SES-10"
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 37,
            cores: []
        ),

        // Upcoming missions for 2025
        Launch(
            id: "future_2025_01",
            name: "Artemis III Support",
            details: "Cargo mission supporting NASA's Artemis III lunar landing.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-04-15T12:00:00.000Z",
            dateUnix: 1744646400,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d96eda699382d09d1ee",
            flightNumber: 402,
            cores: []
        ),

        Launch(
            id: "future_2025_02",
            name: "Mars Sample Return",
            details: "Joint mission with NASA to retrieve samples from Mars.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-07-20T08:30:00.000Z",
            dateUnix: 1753258200,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/eb/0f/Vev7xkUX_o.png",
                    large: "https://images2.imgbox.com/ab/79/Wyc9K7fv_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 403,
            cores: []
        ),

        Launch(
            id: "future_2025_03",
            name: "Starlink Gen3-1",
            details: "First batch of third-generation Starlink satellites.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-09-10T16:45:00.000Z",
            dateUnix: 1757520300,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/1c/f8/nSiaIaJN_o.png",
                    large: "https://images2.imgbox.com/40/e3/dQjxiPTJ_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d95eda69973a809d1ec",
            flightNumber: 404,
            cores: []
        ),

        Launch(
            id: "future_2025_04",
            name: "Dear Moon",
            details: "Private lunar flyby mission with civilian crew.",
            upcoming: true,
            success: nil,
            dateUtc: "2025-11-25T10:15:00.000Z",
            dateUnix: 1763760900,
            links: LaunchLinks(
                patch: LaunchPatch(
                    small: "https://images2.imgbox.com/d2/3b/bQaWiil0_o.png",
                    large: "https://images2.imgbox.com/9a/96/nLppz9HW_o.png"
                ),
                webcast: nil,
                wikipedia: nil
            ),
            rocket: "5e9d0d96eda699382d09d1ee",
            flightNumber: 405,
            cores: []
        )
    ]

    public static let successLaunch = launches[0]
    public static let failureLaunch = launches[3] // FalconSat
    public static let upcomingLaunch = launches[5] // Starship IFT-6
    public static let starshipSuccess = launches[2] // Starship IFT-4
    public static let starshipFailure = launches[4] // Starship IFT-1
}
