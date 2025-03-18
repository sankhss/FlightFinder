//
//  View+Extensions.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import SwiftUI

extension View {
    func removeListRowFormatting() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
            .listRowBackground(Color.clear)
    }
    
    func addFieldBackground(highlighted: Bool = false) -> some View {
        background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.gray.opacity(0.3), radius: 16, x: 6, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(highlighted ? Color.red : Color.clear, lineWidth: 2)
                    )
            }
        )
    }
    
    func addFormLabelStyle() -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
    }
}
