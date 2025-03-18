//
//  FlightListItem.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import Foundation

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
    
    public var formattedDate: String {
        if let date = dateFromString(dateOut) {
            FlightListItem.dateFormatter.string(from: date)
        } else {
            ""
        }
    }
    
    private func dateFromString(_ isoString: String) -> Date? {
        FlightListItem.isoDateFormatter.date(from: isoString)
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM dd, yyyy"
        return formatter
    }()
    
    private static let isoDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return formatter
    }()
}
