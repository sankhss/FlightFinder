//
//  FlightFinderApp.swift
//  FlightFinder
//
//  Created by Samuel Silva on 13/03/25.
//

import SwiftUI

@main
struct FlightFinderApp: App {
    
    private let flightService = FlightService(client: NetworkClient(), url: APIConstants.Endpoints.flightAvailability)
    private let stationsService = StationsService(client: NetworkClient(), url: APIConstants.Endpoints.stations)
    
    var body: some Scene {
        WindowGroup {
            FlightSearchView(viewModel: FlightSearchViewModel(stationsService: stationsService, flightService: flightService))
        }
    }
}
