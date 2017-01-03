//
//  XCTestHTTPStubExtension.swift
//  CatApp_MVP
//
//  Created by Robert on 1/2/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import XCTest
import OHHTTPStubs

@testable import CatApp_MVP

// MARK: - Common

extension XCTest {
    
    func removeStub(_ stub: OHHTTPStubsDescriptor) {
        OHHTTPStubs.removeStub(stub)
    }
}

// MARK: - Stubs for CatProvider

extension XCTest {
    
    func prepeareStubNetworkErrorFor(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false }
            return host == catProvider.providerURL.host
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: NSError(domain: "some domain", code: 1, userInfo: nil))
        }
    }
    
    func prepeareStubServerErrorFor(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false }
            return host == catProvider.providerURL.host
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
        }
    }
    
    func prepeareStubEmptyJSONFor(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false }
            return host == catProvider.providerURL.host
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
    }
    
}

// MARK: - Stubs for Cat

extension XCTest {
    
    func prepeareStubNetworkErrorForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: NSError(domain: "some domain", code: 5, userInfo: nil))
        }
    }
    
    func prepeareStubServerErrorForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil)
        }
    }
    
    func prepeareStubEmptyDataForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
        }
    }
    
}

// MARK: - Constants

extension XCTest {
    enum ImageFileExtensions {
        static let extensions = ["jpg", "jpeg", "png"]
    }
}

