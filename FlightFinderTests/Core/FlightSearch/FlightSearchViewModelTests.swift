//
//  FlightSearchViewModelTests.swift
//  FlightFinder
//
//  Created by Samuel Silva on 16/03/25.
//

import XCTest
@testable import FlightFinder

@MainActor
final class FlightSearchViewModelTests: XCTestCase {
    
    func test_loadStations_success_updatesStations() async {
        let (sut, spy, _) = makeSUT()
        let expectedStations = [
            Station(code: "AAR", name: "Aarhus"),
            Station(code: "CPH", name: "Copenhagen")
        ]
        spy.result = .success(expectedStations)

        await sut.loadStations()
        
        XCTAssertEqual(sut.stations, expectedStations)
        XCTAssertFalse(sut.isStationsLoading)
        XCTAssertNil(sut.stationsError)
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_loadStations_failure_setsErrorState() async {
        let (sut, spy, _) = makeSUT()
        spy.result = .failure(URLError(.cannotConnectToHost))
        
        await sut.loadStations()
        
        XCTAssertTrue(sut.stations.isEmpty)
        XCTAssertFalse(sut.isStationsLoading)
        XCTAssertNotNil(sut.stationsError)
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_loadStations_loadingIndicatorTransitions() async throws {
        let (sut, spy, _) = makeSUT()
        spy.delay = 2
        
        let expectedStations = [Station(code: "AAR", name: "Aarhus")]
        spy.result = .success(expectedStations)
        
        let task = Task { await sut.loadStations() }
        await Task.yield()
        
        XCTAssertTrue(sut.isStationsLoading, "Expected loading state to be true after starting loadStations()")
        
        await task.value
        
        XCTAssertFalse(sut.isStationsLoading, "Expected loading state to be false after loadStations() completes")
    }
    
    func test_searchFlights_success_updatesFlightResults() async {
        let flightResponse = FlightSearchResponse(currency: "EUR", trips: [
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
        
        let (sut, _, spy) = makeSUT()
        spy.result = .success(flightResponse)

        sut.origin = "DUB"
        sut.destination = "STN"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        sut.dateOut = formatter.date(from: "2022-08-09") ?? Date()
        sut.adults = 1
        sut.teens = 0
        sut.children = 0
        
        await sut.searchFlights()

        let expectedItem = FlightSearchViewModel.FlightListItem(dateOut: "2022-08-09T00:00:00.000",
                                                                flightNumber: "FR123",
                                                                regularFare: 105.99)
        
        XCTAssertEqual(sut.flightResults, [expectedItem])
        XCTAssertFalse(sut.isFlightSearchLoading)
        XCTAssertNil(sut.flightsError)
        XCTAssertEqual(spy.searchCallCount, 1)
    }
    
    func test_searchFlights_loadingIndicatorTransitions() async throws {
        let flightResponse = FlightSearchResponse(currency: "EUR", trips: [
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
        
        let (sut, _, spy) = makeSUT()
        spy.delay = 2
        spy.result = .success(flightResponse)
        
        let task = Task { await sut.searchFlights()}
        await Task.yield()
        
        XCTAssertTrue(sut.isFlightSearchLoading, "Expected loading state to be true after starting searchFlights()")
        
        await task.value
        
        XCTAssertFalse(sut.isFlightSearchLoading, "Expected loading state to be false after searchFlights() completes")
    }
    
    func test_searchFlights_failure_setsErrorState() async {
        let (sut, _, spy) = makeSUT()
        spy.result = .failure(URLError(.cannotConnectToHost))
        
        await sut.searchFlights()
        
        XCTAssertTrue(sut.flightResults.isEmpty)
        XCTAssertFalse(sut.isFlightSearchLoading)
        XCTAssertNotNil(sut.flightsError)
        XCTAssertEqual(spy.searchCallCount, 1)
    }
    
    private func makeSUT() -> (sut: FlightSearchViewModel, stationsSpy: StationsServiceSpy, flightSpy: FlightServiceSpy) {
        let stationsSpy = StationsServiceSpy()
        let flightSpy = FlightServiceSpy()
        let sut = FlightSearchViewModel(stationsService: stationsSpy, flightService: flightSpy)
        return (sut, stationsSpy, flightSpy)
    }
    
    final class StationsServiceSpy: StationsServiceProtocol {
        var result: Result<[Station], Error>?
        var loadCallCount = 0
        var delay: Int = 0
        
        func loadStations() async throws -> [Station] {
            loadCallCount += 1
            
            try await Task.sleep(for: .seconds(delay))
            
            switch result {
            case .success(let stations):
                return stations
            case .failure(let error):
                throw error
            case .none:
                fatalError("Result not set")
            }
        }
    }
    
    final class FlightServiceSpy: FlightServiceProtocol {
        var result: Result<FlightSearchResponse, Error>?
        var searchCallCount = 0
        var delay: Int = 0
        
        func searchFlights(params: FlightSearchParameters) async throws -> FlightSearchResponse {
            searchCallCount += 1
            
            try await Task.sleep(for: .seconds(delay))
            
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            case .none:
                fatalError("Result not set in FlightSearchServiceSpy")
            }
        }
    }
}
