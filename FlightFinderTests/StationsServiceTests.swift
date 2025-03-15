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

public protocol StationsServiceProtocol {
    func loadStations() async throws -> [Station]
}

public final class StationsService: StationsServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let url: URL
    
    public init(networkClient: NetworkClientProtocol,
                url: URL) {
        self.networkClient = networkClient
        self.url = url
    }
    
    public func loadStations() async throws -> [Station] {
        let data = try await networkClient.get(url: url)
        let decoder = JSONDecoder()
        let stationsResponse = try decoder.decode(StationsResponse.self, from: data)
        return stationsResponse.stations
    }
    
    private struct StationsResponse: Codable, Equatable {
        public let stations: [Station]
    }
}

public struct Station: Codable, Equatable {
    public let code: String
    public let countryCode: String
    public let name: String
    public let latitude: String
    public let longitude: String
    public let mobileBoardingPass: Bool
}
