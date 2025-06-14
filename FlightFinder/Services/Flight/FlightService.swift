//
//  FlightServiceProtocol.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//

import Foundation

public protocol FlightServiceProtocol {
    func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse
}

public final class FlightService: FlightServiceProtocol {
    private let networkClient: NetworkClientProtocol
    private let url: URL
    
    public init(client: NetworkClientProtocol, url: URL = APIConstants.Endpoints.flightAvailability) {
        self.networkClient = client
        self.url = url
    }
    
    public func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse {
        let request = APIRequest(url: url, parameters: params.asDictionary)
        let data = try await mapNetworkError {
            try await networkClient.get(request)
        }
        
        let decoder = JSONDecoder()
        return try mapDecodingError {
            try decoder.decode(FlightSearchResponse.self, from: data)
        }
    }
}

public extension Encodable {
    var asDictionary: [String: String]? {
        guard let data = try? JSONEncoder().encode(self),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = jsonObject as? [String: Any] else {
            return nil
        }
        
        var result: [String: String] = [:]
        for (key, value) in dict {
            result[key] = "\(value)"
        }
        return result
    }
}
