//
//  FlightSearchViewModel.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import SwiftUI

@MainActor
public final class FlightSearchViewModel: ObservableObject {
    
    @Published var stations: [Station] = []
    @Published var isStationsLoading: Bool = false
    
    @Published var origin: Station?
    @Published var destination: Station?
    @Published var dateOut: Date = Date()
    @Published var adults: Int = 1
    @Published var teens: Int = 0
    @Published var children: Int = 0
    
    @Published var flightResults: [FlightListItem] = []
    @Published var isFlightSearchLoading: Bool = false
    
    @Published var errorMessage: String?
    @Published var hasSearched: Bool = false
    
    private let stationsService: StationsServiceProtocol
    private let flightService: FlightServiceProtocol
    
    public init(stationsService: StationsServiceProtocol, flightService: FlightServiceProtocol) {
        self.stationsService = stationsService
        self.flightService = flightService
    }
    
    public func loadStations() async {
        isStationsLoading = true
        errorMessage = nil
        do {
            let loaded = try await stationsService.loadStations()
            stations = loaded
        } catch {
            errorMessage = error.localizedDescription
            stations = []
        }
        isStationsLoading = false
    }
    
    private var dateOutString: String {
        FlightSearchViewModel.dateFormatter.string(from: dateOut)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    public func searchFlights() async {
        guard let origin, let destination else { return }
        
        isFlightSearchLoading = true
        errorMessage = nil
        hasSearched = false
        
        let params = FlightSearchParameters(origin: origin.code,
                                            destination: destination.code,
                                            dateOut: dateOutString,
                                            adults: adults,
                                            teens: teens,
                                            children: children)
        do {
            let response = try await flightService.searchFlights(params: params)
            var items: [FlightListItem] = []
            for trip in response.trips {
                for date in trip.dates {
                    for flight in date.flights {
                        if let fare = flight.regularFare.fares.first {
                            items.append(FlightListItem(dateOut: date.dateOut,
                                                        flightNumber: flight.flightNumber,
                                                        regularFare: fare.amount))
                        }
                    }
                }
            }
            flightResults = items
            hasSearched = true
        } catch {
            flightResults = []
            errorMessage = error.localizedDescription
        }
        isFlightSearchLoading = false
    }
}
