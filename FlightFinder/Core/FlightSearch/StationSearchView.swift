struct StationSearchView: View {
    let stations: [Station]
    @Binding var selectedStation: String
    @State private var searchText: String = ""
    
    var filteredStations: [Station] {
        if searchText.isEmpty {
            return stations
        } else {
            return stations.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.code.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredStations, id: \.code) { station in
                Button(action: { selectedStation = station.code }) {
                    HStack {
                        Text("\(station.name) (\(station.code))")
                        if station.code == selectedStation {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search for a station")
        .navigationTitle("Select Station")
    }
}