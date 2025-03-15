//
//  FlightSearchResponse.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//

import Foundation

public struct FlightSearchResponse: Codable, Equatable {
    public let currency: String
    public let trips: [Trip]
    
    public struct Trip: Codable, Equatable {
        public let origin: String
        public let destination: String
        public let dates: [FlightDate]
    }
    
    public struct FlightDate: Codable, Equatable {
        public let dateOut: String
        public let flights: [Flight]
    }
    
    public struct Flight: Codable, Equatable {
        public let flightNumber: String
        public let regularFare: RegularFare
    }
    
    public struct RegularFare: Codable, Equatable {
        public let fares: [Fare]
    }
    
    public struct Fare: Codable, Equatable {
        public let amount: Double
    }
}
