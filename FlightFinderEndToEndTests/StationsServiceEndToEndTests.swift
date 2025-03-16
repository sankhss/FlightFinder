//
//  FlightFinderEndToEndTests.swift
//  FlightFinderEndToEndTests
//
//  Created by Samuel Silva on 15/03/25.
//

import XCTest
@testable import FlightFinder

final class StationsServiceEndToEndTests: XCTestCase {
    
    func test_endToEndServerGETStationsResult() async throws {
        let client = NetworkClient()
        let service = StationsService(client: client, url: APIConstants.Endpoints.stations)

        let stations = try await service.loadStations()
        
        XCTAssertFalse(stations.isEmpty, "Expected non-empty stations array")
    }
}
