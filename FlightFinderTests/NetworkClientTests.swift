//
//  NetworkClientTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest

final class NetworkClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_get_returnsData_whenStatusCode200() async throws {
        let sut = NetworkClient()
        
        URLProtocolStub.testResponse = responseWithStatus(200)
        let expectedData = "Success".data(using: .utf8)
        URLProtocolStub.testData = expectedData

        let data = try await sut.get(url: anyURL())
        
        XCTAssertEqual(data, expectedData)
    }
    
    func test_get_throwsError_whenStatusCodeNot200() async {
        let sut = NetworkClient()
        
        URLProtocolStub.testResponse = responseWithStatus(400)
        URLProtocolStub.testData = Data()

        do {
            _ = try await sut.get(url: anyURL())
            XCTFail("Expected client to throw, but it succeeded.")
        } catch {
            XCTAssertTrue(true, "An error was thrown as expected.")
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "https://example.com")!
    }
    
    private func responseWithStatus(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: status, httpVersion: nil, headerFields: nil)!
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
