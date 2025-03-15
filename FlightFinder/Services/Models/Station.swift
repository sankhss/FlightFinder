//
//  Station.swift
//  FlightFinder
//
//  Created by Samuel Silva on 14/03/25.
//

import Foundation

public struct Station: Codable, Equatable {
    public let code: String
    public let countryCode: String
    public let name: String
    public let latitude: String
    public let longitude: String
    public let mobileBoardingPass: Bool
}
