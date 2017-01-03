//
//  CatProviderTest.swift
//  CatApp_MVP
//
//  Created by Robert on 1/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import XCTest

@testable import CatApp_MVP

class CatProviderTest: XCTestCase {
    
    var catProvider: CatProvider!
    
    override func setUp() {
        super.setUp()
        catProvider = CatProvider()
    }
}

// MARK: Tests

extension CatProviderTest {
    
    func test_network_error_request_cat() {
        
        let stubCatProvider = prepeareStubNetworkErrorFor(catProvider: catProvider)
        let expectation = self.expectation(description: "network error")
        
        catProvider.createNewCat { (cat, success) in
            XCTAssertFalse(success)
            XCTAssertNil(cat)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }
    
    func test_server_error_request_cat() {
        let stubCatProvider = prepeareStubServerErrorFor(catProvider: catProvider)
        let expectation = self.expectation(description: "server error")
        
        catProvider.createNewCat { (cat, success) in
            XCTAssertFalse(success)
            XCTAssertNil(cat)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }

    func test_empty_json_response() {
        let stubCatProvider = prepeareStubEmptyJSONFor(catProvider: catProvider)
        let expectation = self.expectation(description: "server error")
        
        catProvider.createNewCat { (cat, success) in
            XCTAssertFalse(success)
            XCTAssertNil(cat)
            
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            self.removeStub(stubCatProvider)
            XCTAssertNil(error)
        }
    }
    
    func test_while_process() {
        let expectation = self.expectation(description: "LoadCat")
        catProvider.createNewCat { (cat, success) in
            XCTAssert(success)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
        }
    }
}
