final class MockStationsService: StationsServiceProtocol {
    private let stations: [Station]
    
    init(stations: [Station]) {
        self.stations = stations
    }
    
    func loadStations() async throws -> [Station] {
        return stations
    }
}

final class MockFlightService: FlightServiceProtocol {
    func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse {
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