//
//  StatusBadge.swift
//  SpaceX
//
//  Created by User on 6/21/25.
//

import SwiftUI

struct StatusBadge: View {
    let statusColor: Color
    let statusIcon: String
    let statusText: LocalizedStringKey
    
    var body: some View {
        Label(title: {
            Text(statusText)
        }, icon: {
            Image(systemName: statusIcon)
        })
        .labelStyle(.iconOnly)
        .font(.title2)
        .fontWeight(.bold)
        .padding(8)
        .background(statusColor.opacity(0.15))
        .foregroundColor(statusColor)
        .clipShape(.circle)
    }
}
