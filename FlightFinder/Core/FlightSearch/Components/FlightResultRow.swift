//
//  FlightResultRow.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import SwiftUI

struct FlightResultRow: View {
    let flight: FlightListItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(flight.formattedDate)
                    .font(.headline)
                Text("Flight \(flight.flightNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("€\(String(format: "%.2f", flight.regularFare))")
                .font(.headline)
        }
        .padding(.vertical, 5)
    }
}
