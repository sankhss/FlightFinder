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
        
        let url = URL(string: "https://nativeapps.ryanair.com/api/v4/Availability")!
        let sut = FlightService(networkClient: clientSpy, url: url)
        
        let response = try await sut.searchFlights(origin: "DUB",
                                                   destination: "STN",
                                                   dateOut: "2022-08-09",
                                                   adt: 1,
                                                   teen: 0,
                                                   chd: 0)
        
        XCTAssertEqual(response, expectedResponse)
    }
    
    func test_searchFlights_includesCorrectQueryParameters() async throws {
        
        let clientSpy = NetworkClientSpy()
        
        let expectedResponse = makeFlightSearchResponse()
        clientSpy.stubbedData = makeJSONResponse(from: expectedResponse)
        
        let url = URL(string: "https://nativeapps.ryanair.com/api/v4/Availability")!
        let sut = FlightService(networkClient: clientSpy, url: url)
        
        let expectedQueries: [String: String] = [
            "origin": "DUB",
            "destination": "STN",
            "dateout": "2022-08-09",
            "adt": "1",
            "teen": "0",
            "chd": "0"
        ]
        
        _ = try await sut.searchFlights(origin: "DUB",
                                        destination: "STN",
                                        dateOut: "2022-08-09",
                                        adt: 1,
                                        teen: 0,
                                        chd: 0)
        
        guard let lastURL = clientSpy.lastURL else {
            XCTFail("No request was intercepted")
            return
        }
        
        guard let components = URLComponents(url: lastURL, resolvingAgainstBaseURL: false),
        let queryItems = components.queryItems else {
            XCTFail("Invalid URL query items")
            return
        }
        
        for (key, expectedValue) in expectedQueries {
            let value = queryItems.first(where: { $0.name == key })?.value
            XCTAssertEqual(value, expectedValue, "Query parameter \(key) should be \(expectedValue)")
        }
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
    
    final class NetworkClientSpy: NetworkClientProtocol {
        var stubbedData: Data?
        var stubbedError: Error?
        var lastURL: URL?
        
        func get(url: URL) async throws -> Data {
            lastURL = url
            if let error = stubbedError {
                throw error
            }
            
            return stubbedData ?? Data()
        }
    }
    
}

public protocol FlightServiceProtocol {
    func searchFlights(origin: String, destination: String, dateOut: String,
                       adt: Int, teen: Int, chd: Int) async throws -> FlightSearchResponse
}

public final class FlightService: FlightServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let url: URL
    
    public init(networkClient: NetworkClientProtocol, url: URL) {
        self.networkClient = networkClient
        self.url = url
    }
    
    public func searchFlights(origin: String, destination: String, dateOut: String,
                              adt: Int, teen: Int, chd: Int) async throws -> FlightSearchResponse {
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "origin", value: origin),
            URLQueryItem(name: "destination", value: destination),
            URLQueryItem(name: "dateout", value: dateOut),
            URLQueryItem(name: "adt", value: "\(adt)"),
            URLQueryItem(name: "teen", value: "\(teen)"),
            URLQueryItem(name: "chd", value: "\(chd)")
        ]
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let data = try await networkClient.get(url: url)
        let decoder = JSONDecoder()
        return try decoder.decode(FlightSearchResponse.self, from: data)
    }
}

public struct FlightSearchResponse: Codable, Equatable {
    public let currency: String
    public let trips: [Trip]
    
    public struct Trip: Codable, Equatable {
        public let origin: String
        public let destination: String
        public let dates: [FlightDate]
    }
    
    public struct FlightDate: Codable, Equatable {
        public let dateOut: String
        public let flights: [Flight]
    }
    
    public struct Flight: Codable, Equatable {
        public let flightNumber: String
        public let regularFare: RegularFare
    }
    
    public struct RegularFare: Codable, Equatable {
        public let fares: [Fare]
    }
    
    public struct Fare: Codable, Equatable {
        public let amount: Double
    }
}
