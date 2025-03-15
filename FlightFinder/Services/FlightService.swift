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

private extension Encodable {
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
