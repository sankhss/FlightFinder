//
//  FlightFinderEndToEndTests.swift
//  FlightFinderEndToEndTests
//
//  Created by Samuel Silva on 15/03/25.
//

import XCTest
@testable import FlightFinder

final class FlightsServiceEndToEndTests: XCTestCase {
    
    func test_endToEndServerGETFlightSearchResult_isNotEmpty() async throws {
        let client = NetworkClient() 
        let service = FlightService(networkClient: client, url: APIConstants.Endpoints.flightAvailability)
        
        let result = try await service.searchFlights(
            params: .init(origin: "DUB", destination: "STN", dateOut: "2022-08-09", adults: 1, teens: 0, children: 0)
        )
        
        XCTAssertFalse(result.trips.isEmpty, "Expected non-empty trips array in flight search result")
    }
}
