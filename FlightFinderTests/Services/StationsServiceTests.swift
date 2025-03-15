//
//  StationsServiceTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest
@testable import FlightFinder

final class StationsServiceTests: XCTestCase {
    
    func test_loadStations_doesNotreturnsStations_whenInvalidJSON() async throws {
        let jsonData = try JSONEncoder().encode("invalid".data(using: .utf8))
        
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedData = jsonData
        
        let url = URL(string: "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json")!
        let sut = StationsService(networkClient: clientSpy, url: url)
        
        do {
            _ = try await sut.loadStations()
            XCTFail("Expected to throw on invalid json data")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    final class NetworkClientSpy: NetworkClientProtocol {
        var stubbedData: Data?
        
        func get(url: URL) async throws -> Data {
            return stubbedData ?? Data()
        }
    }
}
