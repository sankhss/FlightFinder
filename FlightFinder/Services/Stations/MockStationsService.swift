//
//  MockStationsService.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import Foundation

final class MockStationsService: StationsServiceProtocol {
    func loadStations() async throws -> [Station] {
        return [
            Station(code: "DUB", name: "Dublin"),
            Station(code: "STN", name: "London Stansted"),
            Station(code: "JFK", name: "New York JFK"),
            Station(code: "LAX", name: "Los Angeles"),
            Station(code: "CDG", name: "Paris Charles de Gaulle")
        ]
    }
}
