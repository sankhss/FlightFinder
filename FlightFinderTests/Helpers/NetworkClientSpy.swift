//
//  NetworkClientSpy.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//

import Foundation
@testable import FlightFinder

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
