//
//  FlightSearchParameters.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//

import Foundation

public struct FlightSearchParameters: Codable {
    let origin: String
    let destination: String
    let dateOut: String
    let adults: Int
    let teens: Int
    let children: Int
    private let termsOfUseStatus: TermsOfUseStatus = .agreed
    
    enum CodingKeys: String, CodingKey {
        case origin = "origin"
        case destination = "destination"
        case dateOut = "dateout"
        case adults = "adt"
        case teens = "teen"
        case children = "chd"
        case termsOfUseStatus = "ToUs"
        
    }
    
    init(origin: String, destination: String, dateOut: String, adults: Int, teens: Int = 0, children: Int = 0) {
        self.origin = origin
        self.destination = destination
        self.dateOut = dateOut
        self.adults = adults
        self.teens = teens
        self.children = children
    }
    
    private enum TermsOfUseStatus: String, Codable {
        case agreed = "AGREED"
    }
}
