//
//  NetworkClientProtocol.swift
//  FlightFinder
//
//  Created by Samuel Silva on 14/03/25.
//

import Foundation

public protocol NetworkClientProtocol {
    func get(_ request: APIRequest) async throws -> Data
}

public final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func get(_ request: APIRequest) async throws -> Data {
        guard let urlRequest = request.urlRequest else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }
        
        return data
    }
}
