//
//  FlightsServiceTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest
@testable import FlightFinder

final class FlightsServiceTests: XCTestCase {
    
    func test_searchFlights_returnsResponse_whenValidJSON() async throws {
        let expectedResponse = makeFlightSearchResponse()
        let jsonData = makeJSONResponse(from: expectedResponse)
        
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedData = jsonData
        
        let sut = FlightService(networkClient: clientSpy, url: flightSearchURL())
        
        let response = try await sut.searchFlights(
            params: .init(origin: "DUB", destination: "STN", dateout: "2022-08-09", adt: 1)
        )
        
        XCTAssertEqual(response, expectedResponse)
    }
    
    func test_searchFlights_includesCorrectQueryParameters() async throws {
        let clientSpy = NetworkClientSpy()
        
        let expectedResponse = makeFlightSearchResponse()
        clientSpy.stubbedData = makeJSONResponse(from: expectedResponse)
        
        let sut = FlightService(networkClient: clientSpy, url: flightSearchURL())
        
        let expectedQueries: [String: String] = [
            "origin": "DUB",
            "destination": "STN",
            "dateout": "2022-08-09",
            "adt": "1",
            "teen": "0",
            "chd": "0"
        ]
        
        _ = try await sut.searchFlights(
            params: .init(origin: "DUB", destination: "STN", dateout: "2022-08-09", adt: 1)
        )
        
        guard let interceptedURL = clientSpy.lastURL,
              let components = URLComponents(url: interceptedURL, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            XCTFail("No intercepted request or query items found")
            return
        }
        
        let queryDict = Dictionary(uniqueKeysWithValues: queryItems.map { ($0.name, $0.value ?? "") })
        
        for (key, expectedValue) in expectedQueries {
            XCTAssertEqual(queryDict[key], expectedValue, "Query parameter \(key) should be \(expectedValue)")
        }
    }
    
    func test_searchFlights_throwsError_whenNetworkClientFails() async {
        let clientSpy = NetworkClientSpy()
        clientSpy.stubbedError = URLError(.badServerResponse)
        
        let sut = FlightService(networkClient: clientSpy, url: flightSearchURL())
        
        do {
            _ = try await sut.searchFlights(
                params: .init(origin: "DUB", destination: "STN", dateout: "2022-08-09", adt: 1)
            )
            XCTFail("Expected sut to throw, but it succeeded.")
        } catch {
            XCTAssertTrue(true)
        }
    }
    
    private func flightSearchURL() -> URL {
        URL(string: "https://nativeapps.ryanair.com/api/v4/Availability")!
    }
    
    private func makeFlightSearchResponse() -> FlightSearchResponse {
        return FlightSearchResponse(currency: "EUR", trips: [
            FlightSearchResponse.Trip(
                origin: "DUB",
                destination: "STN",
                dates: [
                    FlightSearchResponse.FlightDate(
                        dateOut: "2022-08-09T00:00:00.000",
                        flights: [
                            FlightSearchResponse.Flight(
                                flightNumber: "FR123",
                                regularFare: FlightSearchResponse.RegularFare(
                                    fares: [
                                        FlightSearchResponse.Fare(amount: 105.99)
                                    ]
                                )
                            )
                        ]
                    )
                ]
            )
        ])
    }
    
    private func makeJSONResponse(from response: FlightSearchResponse) -> Data {
        return try! JSONEncoder().encode(response)
    }
}
