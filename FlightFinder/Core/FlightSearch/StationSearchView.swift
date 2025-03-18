//
//  StationSearchView.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import SwiftUI

struct StationSearchView: View {
    let stations: [Station]
    @Binding var selectedStation: String
    @State private var searchText: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    var filteredStations: [Station] {
        if searchText.isEmpty {
            return stations
        } else {
            return stations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredStations, id: \.code) { station in
                    Button(action: {
                        selectedStation = station.code
                        dismiss()
                    }) {
                        Text("\(station.name) (\(station.code))")
                    }
                    .font(.headline)
                    .foregroundStyle(.primary)
                }
            }
            .searchable(text: $searchText, prompt: "Search")
            .navigationTitle("Select Station")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(uiColor: .systemGray))
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedStation: String = ""
    
    return StationSearchView(
        stations: [
            Station(code: "DUB", name: "Dublin"),
            Station(code: "STN", name: "London Stansted"),
            Station(code: "JFK", name: "New York JFK"),
            Station(code: "LAX", name: "Los Angeles"),
            Station(code: "CDG", name: "Paris Charles de Gaulle")
        ],
        selectedStation: $selectedStation
    )
}
