//
//  LaunchYearEntity.swift
//  SpaceXData
//
//  Created by User on 6/24/25.
//

import SwiftData
import Foundation

@Model
final class LaunchYearEntity {
    @Attribute(.unique) var year: Int
    var lastUpdated: Date
    
    init(year: Int, lastUpdated: Date = Date()) {
        self.year = year
        self.lastUpdated = lastUpdated
    }
}
