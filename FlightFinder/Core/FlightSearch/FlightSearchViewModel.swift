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
    @Published var stationsError: String?
    
    @Published var origin: String = ""
    @Published var destination: String = ""
    @Published var dateOut: Date = Date()
    @Published var adults: Int = 1
    @Published var teens: Int = 0
    @Published var children: Int = 0
    
    @Published var flightResults: [FlightListItem] = []
    @Published var isFlightSearchLoading: Bool = false
    @Published var flightsError: String?
    
    private let stationsService: StationsServiceProtocol
    private let flightService: FlightServiceProtocol
    
    public init(stationsService: StationsServiceProtocol, flightService: FlightServiceProtocol) {
        self.stationsService = stationsService
        self.flightService = flightService
    }
    
    public func loadStations() async {
        isStationsLoading = true
        stationsError = nil
        do {
            let loaded = try await stationsService.loadStations()
            stations = loaded
        } catch {
            stationsError = error.localizedDescription
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
        isFlightSearchLoading = true
        flightsError = nil
        
        let params = FlightSearchParameters(origin: origin,
                                            destination: destination,
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
        } catch {
            flightResults = []
            flightsError = error.localizedDescription
        }
        isFlightSearchLoading = false
    }
    
    public struct FlightListItem: Identifiable, Equatable {
        public let id = UUID()
        public let dateOut: String
        public let flightNumber: String
        public let regularFare: Double
        
        public static func == (lhs: FlightListItem, rhs: FlightListItem) -> Bool {
            return lhs.dateOut == rhs.dateOut &&
                   lhs.flightNumber == rhs.flightNumber &&
                   lhs.regularFare == rhs.regularFare
        }
    }
}
