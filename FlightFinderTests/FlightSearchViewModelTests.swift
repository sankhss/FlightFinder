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
        let stationsService = StationsServiceSpy()
        let expectedStations = [
            Station(code: "AAR", name: "Aarhus"),
            Station(code: "CPH", name: "Copenhagen")
        ]
        stationsService.result = .success(expectedStations)
        
        let sut = FlightSearchViewModel(stationsService: stationsService)
        
        await sut.loadStations()
        
        XCTAssertEqual(sut.stations, expectedStations)
        XCTAssertFalse(sut.isStationsLoading)
        XCTAssertNil(sut.stationsError)
        XCTAssertEqual(stationsService.loadCallCount, 1)
    }
    
    final class StationsServiceSpy: StationsServiceProtocol {
        var result: Result<[Station], Error>?
        var loadCallCount = 0
        
        func loadStations() async throws -> [Station] {
            loadCallCount += 1
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
        self.isStationsLoading = true
        self.stationsError = nil
        
        do {
            let loadedStations = try await stationsService.loadStations()
            self.stations = loadedStations
        } catch {
            self.stationsError = error.localizedDescription
        }
        
        self.isStationsLoading = false
    }
}

