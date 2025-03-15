//
//  NetworkClientTests.swift
//  FlightFinderTests
//
//  Created by Samuel Silva on 14/03/25.
//

import XCTest
@testable import FlightFinder

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
        let expectedData = anyData()
        URLProtocolStub.testData = expectedData

        let data = try await sut.get(anyRequest())
        
        XCTAssertEqual(data, expectedData)
    }
    
    func test_get_throwsError_whenStatusCodeNot200() async {
        let sut = NetworkClient()
        
        URLProtocolStub.testResponse = responseWithStatus(400)
        URLProtocolStub.testData = anyData()

        do {
            _ = try await sut.get(anyRequest())
            XCTFail("Expected client to throw, but it succeeded.")
        } catch {
            XCTAssertTrue(true, "An error was thrown as expected.")
        }
    }
    
    func test_get_throwsError_whenDataIsEmpty() async {
        let sut = NetworkClient()
        let url = anyURL()
        
        URLProtocolStub.testResponse = responseWithStatus(200)
        URLProtocolStub.testData = Data()
        
        do {
            _ = try await sut.get(anyRequest())
            XCTFail("Expected client to throw due to empty data, but it succeeded.")
        } catch {
            XCTAssertTrue(true, "An error was thrown as expected.")
        }
    }
    
    private func anyRequest() -> APIRequest {
        APIRequest(url: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://example.com")!
    }
    
    private func responseWithStatus(_ status: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: anyURL(), statusCode: status, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyData() -> Data {
        "Any".data(using: .utf8)!
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
