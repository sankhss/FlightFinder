//
//  FlightSearchView.swift
//  FlightFinder
//
//  Created by Samuel Silva on 17/03/25.
//

import SwiftUI

struct FlightSearchView: View {
    @StateObject private var viewModel: FlightSearchViewModel
    
    init(viewModel: FlightSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                stationPicker(title: "From", selection: $viewModel.origin)
                    .padding(.top)
                stationPicker(title: "To", selection: $viewModel.destination)
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
        }
    }

    private func stationPicker(title: String, selection: Binding<String>) -> some View {
        Text(title)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            .addFieldBackground()
            .removeListRowFormatting()
    }
    
    private var datePicker: some View {
        DatePicker("Departure Date", selection: $viewModel.dateOut, displayedComponents: .date)
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
            Text("Search")
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(height: 50)
        .cornerRadius(10)
        .removeListRowFormatting()
    }
}

extension View {
    func removeListRowFormatting() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
            .listRowBackground(Color.clear)
    }
    
    func addFieldBackground() -> some View {
        background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.init(uiColor: .systemBackground))
                    .shadow(color: Color.gray.opacity(0.3), radius: 16, x: 6, y: 6)
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
