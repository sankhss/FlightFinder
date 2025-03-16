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
        let spy = StationsServiceSpy()
        let expectedStations = [
            Station(code: "AAR", name: "Aarhus"),
            Station(code: "CPH", name: "Copenhagen")
        ]
        spy.result = .success(expectedStations)
        
        let sut = FlightSearchViewModel(stationsService: spy)
        
        await sut.loadStations()
        
        XCTAssertEqual(sut.stations, expectedStations)
        XCTAssertFalse(sut.isStationsLoading)
        XCTAssertNil(sut.stationsError)
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_loadStations_failure_setsErrorState() async {
        let spy = StationsServiceSpy()
        spy.result = .failure(URLError(.cannotConnectToHost))
        
        let sut = FlightSearchViewModel(stationsService: spy)
        
        await sut.loadStations()
        
        XCTAssertTrue(sut.stations.isEmpty)
        XCTAssertFalse(sut.isStationsLoading)
        XCTAssertNotNil(sut.stationsError)
        XCTAssertEqual(spy.loadCallCount, 1)
    }
    
    func test_loadStations_loadingIndicatorTransitions() async throws {
        let spy = StationsServiceSpy()
        spy.delay = 2
        
        let expectedStations = [Station(code: "AAR", name: "Aarhus")]
        spy.result = .success(expectedStations)
        
        let sut = FlightSearchViewModel(stationsService: spy)
        
        let task = Task { await sut.loadStations() }
        await Task.yield()

        XCTAssertTrue(sut.isStationsLoading, "Expected loading state to be true after starting loadStations()")
        
        await task.value
        
        XCTAssertFalse(sut.isStationsLoading, "Expected loading state to be false after loadStations() completes")
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
}

import SwiftUI

@MainActor
final class FlightSearchViewModel: ObservableObject {

    @Published var stations: [Station] = []
    @Published var isStationsLoading: Bool = false
    @Published var stationsError: String?
    
    private let stationsService: StationsServiceProtocol
    
    init(stationsService: StationsServiceProtocol) {
        self.stationsService = stationsService
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
}

