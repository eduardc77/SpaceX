//
//  YearToggleButton.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI

struct YearToggleButton: View {
    let year: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(String(year))
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
