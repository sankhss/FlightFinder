//
//  NetworkClientProtocol.swift
//  FlightFinder
//
//  Created by Samuel Silva on 14/03/25.
//

import Foundation

protocol NetworkClientProtocol {
    func get(url: URL) async throws -> Data
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard !data.isEmpty else {
            throw URLError(.zeroByteResource)
        }
        
        return data
    }
}
