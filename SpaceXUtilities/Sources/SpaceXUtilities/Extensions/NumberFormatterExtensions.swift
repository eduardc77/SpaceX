//
//  NumberFormatterExtensions.swift
//  SpaceXUtilities
//
//  Created by User on 6/22/25.
//

import Foundation

public extension NumberFormatter {
    /// Formats an integer with decimal style (adds commas for thousands)
    static func decimal(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    /// Formats a 64-bit integer with decimal style (adds commas for thousands)
    static func decimal(_ number: Int64) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
    /// Formats large numbers in abbreviated form (e.g., "137 billion", "12.5 million")
    static func abbreviated(_ number: Int64) -> String {
        let billion: Int64 = 1_000_000_000
        let million: Int64 = 1_000_000
        let thousand: Int64 = 1_000
        
        switch number {
        case billion...:
            let value = Double(number) / Double(billion)
            return value.truncatingRemainder(dividingBy: 1) == 0 ? 
            "\(Int(value)) billion" : 
            String(format: "%.1f billion", value)
        case million..<billion:
            let value = Double(number) / Double(million)
            return value.truncatingRemainder(dividingBy: 1) == 0 ? 
            "\(Int(value)) million" : 
            String(format: "%.1f million", value)
        case thousand..<million:
            let value = Double(number) / Double(thousand)
            return value.truncatingRemainder(dividingBy: 1) == 0 ? 
            "\(Int(value))K" : 
            String(format: "%.1fK", value)
        default:
            return decimal(number)
        }
    }
}
