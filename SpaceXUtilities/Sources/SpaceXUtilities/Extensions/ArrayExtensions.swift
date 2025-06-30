//
//  ArrayExtensions.swift
//  SpaceXUtilities
//
//  Created by User on 7/1/25.
//

public extension Array {

    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
