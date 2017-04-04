//
//  XCTestHTTPStubExtension.swift
//
//  Created by R. Fogash, V. Ahosta
//  Copyright (c) 2017 Thinkmobiles
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
            let response = OHHTTPStubsResponse(error: NSError(domain: "some domain", code: 1, userInfo: nil))
            response.responseTime(ImageFileExtensions.defaultResponseTime)
            return response
        }
    }
    
    func prepeareStubServerErrorFor(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false }
            return host == catProvider.providerURL.host
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil).responseTime(ImageFileExtensions.defaultResponseTime)
        }
    }
    
    func prepeareStubEmptyJSONFor(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false }
            return host == catProvider.providerURL.host
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil).responseTime(ImageFileExtensions.defaultResponseTime)
        }
    }
    
    func prepeareStubLoadJsonOK(catProvider: CatProvider) -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let host = urlRequest.url?.host else { return false; }
            return host == catProvider.providerURL.host!
        }, withStubResponse: { (urlRequest) -> OHHTTPStubsResponse in
            let jsonString = "{\"file\":\""+ImageFileExtensions.stubImageUrl+"\"}"
            let jsonData = jsonString.data(using: .utf8)!
            return OHHTTPStubsResponse(data: jsonData, statusCode: 200, headers: nil).responseTime(ImageFileExtensions.defaultResponseTime)
        })
    }
    
}

// MARK: - Stubs for Cat

extension XCTest {
    
    func prepeareStubNetworkErrorForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(error: NSError(domain: "some domain", code: 5, userInfo: nil)).responseTime(ImageFileExtensions.defaultResponseTime)
        }
    }
    
    func prepeareStubServerErrorForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 400, headers: nil).responseTime(ImageFileExtensions.defaultResponseTime)
        }
    }
    
    func prepeareStubEmptyDataForImageRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let fileExtension = urlRequest.url?.pathExtension else { return false }
            return ImageFileExtensions.extensions.contains(fileExtension)
        }) { (urlRequest) -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: 200, headers: nil).responseTime(ImageFileExtensions.defaultResponseTime)
        }
    }
    
    func prepeareStubForSuccessImageLoadRequest() -> OHHTTPStubsDescriptor {
        return OHHTTPStubs.stubRequests(passingTest: { (urlRequest) -> Bool in
            guard let requestURL = urlRequest.url else { return false }
            return requestURL.absoluteString == ImageFileExtensions.stubImageUrl
        }, withStubResponse: { (urlRequst) -> OHHTTPStubsResponse in
            let stubFilePath = OHPathForFile(ImageFileExtensions.stubbedCatImageName, self.classForCoder)!
            return OHHTTPStubsResponse(fileAtPath: stubFilePath, statusCode: 200, headers: ["Content-Type":"image/jpg"]).responseTime(ImageFileExtensions.defaultResponseTime)
        })
    }
    
}

// MARK: - Constants

extension XCTest {
    enum ImageFileExtensions {
        static let extensions = ["jpg", "jpeg", "png"]
        static let stubbedCatImageName = "stubbedCatImage.jpg"
        static let stubImageUrl = "http://stubHost.org/stubPath/" + stubbedCatImageName
        static let defaultResponseTime: TimeInterval = 2.0
    }
}

