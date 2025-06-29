//
//  SortOptionPicker.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain

struct SortOptionPicker: View {
    @Binding var selectedOption: LaunchSortOption
    
    var body: some View {
        ForEach([LaunchSortOption.dateDescending, .dateAscending, .nameAscending, .nameDescending], id: \.self) { option in
            Button {
                selectedOption = option
            } label: {
                HStack {
                    Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(selectedOption == option ? .blue : .gray)
                    
                    Text(option.localizedDisplayName)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: option.iconName)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}
