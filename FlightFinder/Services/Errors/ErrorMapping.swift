//
//  ErrorMapping.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import Foundation

func mapNetworkError<T>(_ operation: () async throws -> T) async throws -> T {
    do {
        return try await operation()
    } catch let error as URLError {
        switch error.code {
        case .badURL:
            throw FlightFinderError.invalidURL
        case .badServerResponse:
            throw FlightFinderError.serverError(statusCode: error.errorCode)
        case .zeroByteResource:
            throw FlightFinderError.emptyData
        default:
            throw FlightFinderError.unknown(error)
        }
    } catch {
        throw FlightFinderError.unknown(error)
    }
}

func mapDecodingError<T>(_ operation: () throws -> T) throws -> T {
    do {
        return try operation()
    } catch let decodingError as DecodingError {
        throw FlightFinderError.decodingError(underlying: decodingError)
    } catch {
        throw FlightFinderError.unknown(error)
    }
}
