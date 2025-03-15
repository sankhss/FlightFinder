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
    let dateout: String
    let adt: Int
    let teen: Int
    let chd: Int
    
    init(origin: String, destination: String, dateout: String, adt: Int, teen: Int = 0, chd: Int = 0) {
        self.origin = origin
        self.destination = destination
        self.dateout = dateout
        self.adt = adt
        self.teen = teen
        self.chd = chd
    }
}
