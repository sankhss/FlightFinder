//
//  APIConstants.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//


import Foundation

public enum APIConstants {
    public enum Endpoints {
        public static let flightAvailability = URL(string: "https://nativeapps.ryanair.com/api/v4/Availability")!
        public static let stations = URL(string: "https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com/stations.json")!
    }
    
    public static let headers: [String: String] = [
        "Content-Type": "application/json",
        "client": "ios",
        "client-version": "3.999.0"
    ]
}
