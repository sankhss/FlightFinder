//
//  NetworkClientTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest

final class NetworkClientTests: XCTestCase {
    
    func test_get_returnsData_whenStatusCode200() async throws {
        let sut = NetworkClient()
        let url = URL(string: "https://example.com")!
        let expectedData = "Success".data(using: .utf8)
        
        URLProtocolStub.testResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolStub.testData = expectedData
        
        URLProtocolStub.startInterceptingRequests()
        let data = try await sut.get(url: url)
        URLProtocolStub.stopInterceptingRequests()
        
        XCTAssertEqual(data, expectedData)
    }
    
    func test_get_throwsError_whenStatusCodeNot200() async {
        let sut = NetworkClient()
        
        let expectedData = "Failure".data(using: .utf8)
        URLProtocolStub.testData = expectedData
        
        let url = URL(string: "https://example.com")!
        let response = HTTPURLResponse(url: url,
                                       statusCode: 201,
                                       httpVersion: nil,
                                       headerFields: nil)
        URLProtocolStub.testResponse = response
        
        URLProtocolStub.startInterceptingRequests()
        do {
            let _ = try await sut.get(url: url)
            XCTFail("Expected client to throw, but it succeeded.")
        } catch {
            XCTAssertTrue(true, "An error was thrown as expected.")
        }
        URLProtocolStub.stopInterceptingRequests()
    }
    
    final class URLProtocolStub: URLProtocol {
        static var testResponse: URLResponse?
        static var testData: Data?
        
        override class func canInit(with request: URLRequest) -> Bool {
            true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.testData {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.testResponse {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            testResponse = nil
            testData = nil
        }
    }
}

protocol NetworkClientProtocol {
    func get(url: URL) async throws -> Data
}

final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}
