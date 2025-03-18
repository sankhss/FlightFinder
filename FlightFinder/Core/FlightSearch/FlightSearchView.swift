//
//  FlightSearchView.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import SwiftUI

struct FlightSearchView: View {
    @StateObject private var viewModel: FlightSearchViewModel
    
    @State private var isSelectingOrigin = false
    @State private var isSelectingDestination = false
    @State private var highlightOriginField = false
    
    init(viewModel: FlightSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                stationPicker(title: "From", selection: $viewModel.origin, highlight: highlightOriginField)
                    .onTapGesture {
                        isSelectingOrigin = true
                    }
                    .padding(.top)
                
                stationPicker(title: "To", selection: $viewModel.destination)
                    .onTapGesture {
                        if viewModel.origin.isEmpty {
                            highlightOriginField = true
                        } else {
                            isSelectingDestination = true
                        }
                    }
                    .padding(.top)
                
                datePicker
                    .padding(.top)
                
                passengerStepper(title: "Adults", count: $viewModel.adults, range: 1...6)
                    .padding(.top)
                passengerStepper(title: "Teens", count: $viewModel.teens, range: 0...6)
                    .padding(.top)
                passengerStepper(title: "Children", count: $viewModel.children, range: 0...6)
                    .padding(.top)
                
                searchButton
                    .padding(.top)
            }
            .navigationTitle("Find Flights")
            .fullScreenCover(isPresented: $isSelectingOrigin) {
                StationSearchView(stations: viewModel.stations, selectedStation: $viewModel.origin)
            }
            .fullScreenCover(isPresented: $isSelectingDestination) {
                StationSearchView(stations: viewModel.stations, selectedStation: $viewModel.destination)
            }
            .task {
                await viewModel.loadStations()
            }
        }
    }
    
    private func stationPicker(title: String, selection: Binding<String>, highlight: Bool = false) -> some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .addFieldBackground(highlighted: highlight)
            .removeListRowFormatting()
    }
    
    private var datePicker: some View {
        DatePicker("Departure", selection: $viewModel.dateOut, displayedComponents: .date)
            .padding()
            .addFormLabelStyle()
            .removeListRowFormatting()
            .addFieldBackground()
            .datePickerStyle(.compact)
    }
    
    private func passengerStepper(title: String, count: Binding<Int>, range: ClosedRange<Int>) -> some View {
        Stepper(value: count, in: range) {
            HStack {
                Text(title)
                Spacer()
                Text("\(count.wrappedValue)")
            }
        }
        .padding()
        .addFormLabelStyle()
        .addFieldBackground()
        .removeListRowFormatting()
    }
    
    private var searchButton: some View {
        Button {
            Task {
                await viewModel.searchFlights()
            }
        } label: {
            HStack {
                Spacer()
                if viewModel.isFlightSearchLoading {
                    ProgressView()
                } else {
                    Text("Search")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .disabled(viewModel.isFlightSearchLoading || viewModel.origin.isEmpty || viewModel.destination.isEmpty)
        .frame(height: 50)
        .background(viewModel.isFlightSearchLoading || viewModel.origin.isEmpty || viewModel.destination.isEmpty ? Color.gray : Color.blue)
        .cornerRadius(10)
        .removeListRowFormatting()
    }
}

#Preview {
    FlightSearchView(viewModel: FlightSearchViewModel(
        stationsService: MockStationsService(),
        flightService: MockFlightService()
    ))
}

extension View {
    func removeListRowFormatting() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
            .listRowBackground(Color.clear)
    }
    
    func addFieldBackground(highlighted: Bool = false) -> some View {
        background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: Color.gray.opacity(0.3), radius: 16, x: 6, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(highlighted ? Color.red : Color.clear, lineWidth: 2)
                    )
            }
        )
    }
    
    func addFormLabelStyle() -> some View {
        self
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
    }
}
