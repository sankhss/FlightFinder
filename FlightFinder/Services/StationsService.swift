//
//  StationsServiceProtocol.swift
//  FlightFinder
//
//  Created by Samuel Silva on 14/03/25.
//

import Foundation

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
        let request = APIRequest(url: url, headers: [
            "Content-Type": "application/json",
            "client": "ios",
            "client-version": "3.999.0"
        ])
        let data = try await networkClient.get(request)
        let decoder = JSONDecoder()
        let stationsResponse = try decoder.decode(StationsResponse.self, from: data)
        return stationsResponse.stations
    }
    
    private struct StationsResponse: Codable, Equatable {
        public let stations: [Station]
    }
}
