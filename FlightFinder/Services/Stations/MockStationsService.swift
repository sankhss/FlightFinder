//
//  MockStationsService.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import Foundation

final class MockStationsService: StationsServiceProtocol {
    
    let shouldDelay: Bool
    
    init(shouldDelay: Bool = false) {
        self.shouldDelay = shouldDelay
    }
    
    func loadStations() async throws -> [Station] {
        if shouldDelay {
            try await Task.sleep(for: .seconds(3))
        }
        
        return [
            Station(code: "DUB", name: "Dublin"),
            Station(code: "STN", name: "London Stansted"),
            Station(code: "JFK", name: "New York JFK"),
            Station(code: "LAX", name: "Los Angeles"),
            Station(code: "CDG", name: "Paris Charles de Gaulle")
        ]
    }
}
