//
//  Binding+Extensions.swift
//  FlightFinder
//
//  Created by Samuel Silva on 18/03/25.
//

import SwiftUI

extension Binding where Value == Bool {
    init<T: Sendable>(ifNotNil optional: Binding<T?>) {
        self.init {
            optional.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                optional.wrappedValue = nil
            }
        }
    }
}
