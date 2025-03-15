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
    func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse
}

public final class FlightService: FlightServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let url: URL
    
    public init(networkClient: NetworkClientProtocol, url: URL) {
        self.networkClient = networkClient
        self.url = url
    }
    
    public func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.queryItems = params.queryItems
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

public struct FlightSearchParameters: Codable {
    let origin: String
    let destination: String
    let dateout: String
    let adt: Int
    let teen: Int
    let chd: Int
    
    init(origin: String, destination: String, dateout: String, adt: Int, teen: Int = 0, chd: Int = 0) {
        self.origin = origin
        self.destination = destination
        self.dateout = dateout
        self.adt = adt
        self.teen = teen
        self.chd = chd
    }
}

extension Encodable {
    var queryItems: [URLQueryItem]? {
        guard let dictionary = try? asDictionary() else { return nil }
        return dictionary.compactMap { key, value in
            if let stringValue = value as? String {
                return URLQueryItem(name: key, value: stringValue)
            } else if let number = value as? NSNumber {
                return URLQueryItem(name: key, value: number.stringValue)
            } else {
                return nil
            }
        }
    }
    
    private func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let dictionaryAny = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dictionary = dictionaryAny as? [String: Any] else {
            throw URLError(.cannotParseResponse)
        }
        return dictionary
    }
}
