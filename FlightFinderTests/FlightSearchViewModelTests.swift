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

import SwiftUI

@MainActor
final class FlightSearchViewModel: ObservableObject {
    
    @Published var stations: [Station] = []
    @Published var isStationsLoading: Bool = false
    @Published var stationsError: String?
    
    @Published var origin: String = ""
    @Published var destination: String = ""
    @Published var dateOut: Date = Date()
    @Published var adults: Int = 1
    @Published var teens: Int = 0
    @Published var children: Int = 0
    
    @Published var flightResults: [FlightListItem] = []
    @Published var isFlightSearchLoading: Bool = false
    
    private let stationsService: StationsServiceProtocol
    private let flightService: FlightServiceProtocol
    
    init(stationsService: StationsServiceProtocol, flightService: FlightServiceProtocol) {
        self.stationsService = stationsService
        self.flightService = flightService
    }
    
    func loadStations() async {
        isStationsLoading = true
        stationsError = nil
        do {
            let loaded = try await stationsService.loadStations()
            stations = loaded
        } catch {
            stationsError = error.localizedDescription
            stations = []
        }
        isStationsLoading = false
    }
    
    private var dateOutString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: dateOut)
    }
    
    func searchFlights() async {
        isFlightSearchLoading = true
        
        let params = FlightSearchParameters(origin: origin,
                                            destination: destination,
                                            dateOut: dateOutString,
                                            adults: adults,
                                            teens: teens,
                                            children: children)
        do {
            let response = try await flightService.searchFlights(params: params)
            var items: [FlightListItem] = []
            for trip in response.trips {
                for date in trip.dates {
                    for flight in date.flights {
                        if let fare = flight.regularFare.fares.first {
                            items.append(FlightListItem(dateOut: date.dateOut,
                                                        flightNumber: flight.flightNumber,
                                                        regularFare: fare.amount))
                        }
                    }
                }
            }
            flightResults = items
        } catch {
            flightResults = []
        }
        isFlightSearchLoading = false
    }
    
    public struct FlightListItem: Identifiable, Equatable {
        public let id = UUID()
        public let dateOut: String
        public let flightNumber: String
        public let regularFare: Double
        
        public static func == (lhs: FlightListItem, rhs: FlightListItem) -> Bool {
            return lhs.dateOut == rhs.dateOut &&
                   lhs.flightNumber == rhs.flightNumber &&
                   lhs.regularFare == rhs.regularFare
        }
    }
}
