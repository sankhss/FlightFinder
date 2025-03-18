//
//  FlightFinderError.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import Foundation

public enum FlightFinderError: LocalizedError {
    case invalidURL
    case serverError(statusCode: Int)
    case emptyData
    case decodingError(underlying: Error)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is not valid."
        case .serverError(let statusCode):
            return "The server responded with an error (status code: \(statusCode)). Please try again later."
        case .emptyData:
            return "No data was received from the server."
        case .decodingError(let underlying):
            return "Failed to process the data from the server. \(underlying.localizedDescription)"
        case .unknown(let error):
            return "An unexpected error occurred. \(error.localizedDescription)"
        }
    }
}
