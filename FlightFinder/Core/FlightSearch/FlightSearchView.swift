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
            ScrollViewReader { proxy in
                List {
                    if viewModel.isStationsLoading {
                        loadingSection
                    } else {
                        searchForm
                    }
                    
                    if viewModel.hasSearched {
                        Section {
                            if !viewModel.flightResults.isEmpty {
                                Section(header: Text(Strings.FlightSearch.availableFlights)) {
                                    ForEach(viewModel.flightResults) { flight in
                                        FlightResultRow(flight: flight)
                                    }
                                    .id("flightResultsStart")
                                }
                            } else if !viewModel.isFlightSearchLoading {
                                Section {
                                    Text(Strings.FlightSearch.noFlightsFound)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                }
                            }
                        }
                    }
                }
                .navigationTitle(Strings.FlightSearch.title)
                .fullScreenCover(isPresented: $isSelectingOrigin) {
                    StationSearchView(stations: viewModel.stations, selectedStation: $viewModel.origin)
                        .onDisappear { highlightOriginField = false }
                }
                .fullScreenCover(isPresented: $isSelectingDestination) {
                    StationSearchView(stations: viewModel.stations, selectedStation: $viewModel.destination)
                }
                .task {
                    await viewModel.loadStations()
                }
                .onChange(of: viewModel.flightResults) { _, _ in
                    scrollToResults(proxy)
                }
                .alert("", isPresented: Binding(ifNotNil: $viewModel.errorMessage)) {
                    Button(Strings.FlightSearch.ok) {}
                } message: {
                    if let message = viewModel.errorMessage {
                        Text(message)
                    }
                }
            }
        }
    }

    private var searchForm: some View {
        Section {
            stationPicker(title: Strings.FlightSearch.fromPlaceholder, selection: $viewModel.origin, highlight: highlightOriginField)
                .onTapGesture {
                    isSelectingOrigin = true
                }
                .padding(.top)

            stationPicker(title: Strings.FlightSearch.toPlaceholder, selection: $viewModel.destination)
                .onTapGesture {
                    if viewModel.origin == nil {
                        highlightOriginField = true
                    } else {
                        isSelectingDestination = true
                    }
                }
                .padding(.top)

            datePicker
                .padding(.top)

            passengerStepper(title: Strings.FlightSearch.adults, count: $viewModel.adults, range: 1...6)
                .padding(.top)
            passengerStepper(title: Strings.FlightSearch.teens, count: $viewModel.teens, range: 0...6)
                .padding(.top)
            passengerStepper(title: Strings.FlightSearch.children, count: $viewModel.children, range: 0...6)
                .padding(.top)

            searchButton
                .padding(.top)
        }
    }
    
    private var loadingSection: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .removeListRowFormatting()
    }
    
    private func scrollToResults(_ proxy: ScrollViewProxy) {
        if !viewModel.flightResults.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    proxy.scrollTo("flightResultsStart", anchor: .top)
                }
            }
        }
    }
    
    private func stationPicker(title: String, selection: Binding<Station?>, highlight: Bool = false) -> some View {
        Text(selection.wrappedValue?.name ?? title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundStyle(selection.wrappedValue != nil ? .primary : .secondary)
            .addFormLabelStyle()
            .addFieldBackground(highlighted: highlight)
            .removeListRowFormatting()
    }
    
    private var datePicker: some View {
        DatePicker(Strings.FlightSearch.departure, selection: $viewModel.dateOut, displayedComponents: .date)
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
                    Text(Strings.FlightSearch.search)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .disabled(viewModel.isButtonStateInvalid())
        .frame(height: 50)
        .background(viewModel.isButtonStateInvalid() ? Color.gray : Color.blue)
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

#Preview("Error") {
    FlightSearchView(viewModel: FlightSearchViewModel(
        stationsService: MockStationsService(),
        flightService: MockFlightService(showError: true)
    ))
}

#Preview("Loading") {
    FlightSearchView(viewModel: FlightSearchViewModel(
        stationsService: MockStationsService(shouldDelay: true),
        flightService: MockFlightService()
    ))
}
