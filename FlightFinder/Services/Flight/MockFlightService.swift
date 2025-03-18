//
//  MockFlightService.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import Foundation

final class MockFlightService: FlightServiceProtocol {
    
    let showError: Bool
    
    init(showError: Bool = false) {
        self.showError = showError
    }
    
    func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse {
        
        if showError {
            throw FlightFinderError.serverError(statusCode: 500)
        }
        
        return FlightSearchResponse(currency: "EUR", trips: [
            FlightSearchResponse.Trip(
                origin: "DUB",
                destination: "STN",
                dates: [
                    FlightSearchResponse.FlightDate(
                        dateOut: "2022-08-09T00:00:00.000",
                        flights: [
                            FlightSearchResponse.Flight(
                                flightNumber: "FR123",
                                regularFare: FlightSearchResponse.RegularFare(
                                    fares: [
                                        FlightSearchResponse.Fare(amount: 105.99)
                                    ]
                                )
                            )
                        ]
                    )
                ]
            )
        ])
    }
}
