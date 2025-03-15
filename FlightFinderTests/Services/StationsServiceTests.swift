//
//  StationsServiceTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest
@testable import FlightFinder

final class StationsServiceTests: XCTestCase {
    
    func test_loadStations_doesNotReturnsStations_whenInvalidJSON() async throws {
        let jsonData = try JSONEncoder().encode("invalid".data(using: .utf8))
        
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedData = jsonData

        let sut = StationsService(networkClient: clientSpy, url: stationsURL())
        
        do {
            _ = try await sut.loadStations()
            XCTFail("Expected to throw on invalid json data")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    func test_loadStations_returnsStations_validJSON() async throws {
        let station1 = makeStation(code: "AAR", name: "Aarhus")
        let station2 = makeStation(code: "CPH", name: "Copenhagen")
        let expectedStations = [station1.model, station2.model]
        let jsonData = makeStationsJSON([station1.json, station2.json])
        
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedData = jsonData
        
        let sut = StationsService(networkClient: clientSpy, url: stationsURL())
        
        let stations = try await sut.loadStations()
        XCTAssertEqual(stations, expectedStations)
    }
    
    func test_loadStations_throwsError_whenNetworkClientFails() async {
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedError = URLError(.badServerResponse)
        
        let sut = StationsService(networkClient: clientSpy, url: stationsURL())

        do {
            _ = try await sut.loadStations()
            XCTFail("Expected to throw, but it succeeded.")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    private func makeStation(code: String, name: String) -> (model: Station, json: [String: Any]) {
        let model = Station(code: code, name: name)
        let json: [String: Any] = [
            "code": code,
            "name": name,
        ]
        return (model, json)
    }

    private func makeStationsJSON(_ items: [[String: Any]]) -> Data {
        let json = ["stations": items]
        return try! JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    private func stationsURL() -> URL {
        URL(string: "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json")!
    }
}
