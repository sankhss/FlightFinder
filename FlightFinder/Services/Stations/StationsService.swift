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
    
    public init(client: NetworkClientProtocol,
                url: URL = APIConstants.Endpoints.stations) {
        self.networkClient = client
        self.url = url
    }
    
    public func loadStations() async throws -> [Station] {
        let request = APIRequest(url: url)
        let data = try await mapNetworkError {
            try await networkClient.get(request)
        }
        
        let decoder = JSONDecoder()
        let stationsResponse = try mapDecodingError {
            try decoder.decode(StationsResponse.self, from: data)
        }
        
        return stationsResponse.stations
    }
    
    private struct StationsResponse: Codable, Equatable {
        public let stations: [Station]
    }
}
