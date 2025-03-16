//
//  APIRequest.swift
//  FlightFinder
//
//  Created by Samuel Silva on 15/03/25.
//

import Foundation

public struct APIRequest {
    let url: URL
    let parameters: [String: String]?
    let headers: [String: String]?

    init(url: URL, 
         parameters: [String: String]? = nil, 
         headers: [String: String]? = APIConstants.headers) {
        self.url = url
        self.parameters = parameters
        self.headers = headers
    }

    var urlRequest: URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        if let parameters = parameters, !parameters.isEmpty {
            components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let finalURL = components.url else {
            return nil
        }

        var request = URLRequest(url: finalURL)
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}
