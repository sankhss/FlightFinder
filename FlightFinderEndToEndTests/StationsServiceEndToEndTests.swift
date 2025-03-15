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
        let url = URL(string: "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json")!
        let client = NetworkClient()
        let service = StationsService(networkClient: client, url: url)

        let stations = try await service.loadStations()
        
        XCTAssertFalse(stations.isEmpty, "Expected non-empty stations array")
    }
}
