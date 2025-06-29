//
//  MockURLProtocol.swift
//  SpaceXNetwork
//
//  Created by User on 6/25/25.
//

import Foundation

class MockURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true  // Mock all requests in tests
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockError", code: 404, userInfo: nil))
            return
        }
        
        do {
            let (response, data) = try handler(request)
            
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
} 
