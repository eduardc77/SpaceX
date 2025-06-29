//
//  SuccessFilterPicker.swift
//  SpaceX
//
//  Created by User on 6/23/25.
//

import SwiftUI
import SpaceXDomain

struct SuccessFilterPicker: View {
    @Binding var selectedStatus: SuccessFilter
    
    var body: some View {
        ForEach([SuccessFilter.all, .successful, .failed], id: \.self) { status in
            Button {
                selectedStatus = status
            } label: {
                HStack {
                    Image(systemName: selectedStatus == status ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(selectedStatus == status ? .blue : .gray)
                    
                    Text(status.localizedDisplayName)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if status != .all {
                        Image(systemName: status == .successful ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(status == .successful ? .green : .red)
                    }
                }
                .padding(.vertical, 4)
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}
