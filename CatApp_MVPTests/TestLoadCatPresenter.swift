//
//  PresenterTest.swift
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

@testable import CatApp_MVP

class MockUI: LoadCatViewProtocol {
    
    private var presenter: LoadCatPresenterProtocol!
    
    var isLoading: Bool
    var imageTitle: String?
    var image: Data?
    
    init() {
        isLoading = false
        imageTitle = nil
        image = nil
    }
    
    func resetState() {
        isLoading = false
        imageTitle = nil
        image = nil
        didCallEditScene = nil
    }
    
    func updateLoadingState(_ loadingState: Bool) {
        self.isLoading = loadingState
    }
    
    func updateTitle(_ imageTitle: String?) {
        self.imageTitle = imageTitle
    }
    
    func updateImage(_ image: Data?) {
        self.image = image
    }
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter as! LoadCatPresenterProtocol
        self.presenter?.updateUI()
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
    
    func finishedEdit() {
        
    }
    
    var didCallEditScene: ( (_ pressenter: Presenter)->Void )?
    func showEditScene(withPresenter presenter: Presenter) {
        if let callback = didCallEditScene {
            callback(presenter)
        }
    }
}

typealias UUI = () -> Void

class TestablePresenter: LoadCatPresenter {
    
    var updateUICallback: UUI!
    
    override init() {
        super.init()
        updateUICallback = nil
    }
    
    override func installView(_ view: View) {
        self.view = view as! LoadCatViewProtocol
    }
    
    override func updateUI() {
        super.updateUI()
        if let callback = updateUICallback {
            callback()
        }
    }
}

class PresenterTest: XCTestCase {
    
    var catProvider: CatProvider!
    var presenter: TestablePresenter!
    var view: MockUI!
    
    override func setUp() {
        super.setUp()
        
        catProvider = CatProvider()
        view = MockUI()
        presenter = TestablePresenter()
        presenter.catProvider = catProvider
        presenter.installView(view)
        view.setPresenter(presenter)
    }
    
    override func tearDown() {
        view.resetState()
    }
}

// MARK: Cat provider level cases

extension PresenterTest {
    
    func test_cat_provider_network_error() {
        
        let networkErrorStub = self.prepeareStubServerErrorFor(catProvider: catProvider)
        
        let loadingCatStateIdentifier = "Loading state"
        let loadCatFinishedStateIdentifier = "Load finished"
        
        let expectationLoadingCatState = self.expectation(description: loadingCatStateIdentifier)
        let expectationLoadCatFinishedState = self.expectation(description: loadCatFinishedStateIdentifier)
        
        var expectationsList = [expectationLoadingCatState, expectationLoadCatFinishedState]
        
        presenter.updateUICallback = { () -> Void in
            guard let expectation = expectationsList.first else {
                XCTAssertNotNil(expectationsList.first)
                return
            }
            expectationsList.removeFirst()
            
            if expectation.description == loadingCatStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == loadCatFinishedStateIdentifier {
                XCTAssertFalse(self.view.isLoading)
                XCTAssertEqual(self.view.imageTitle, LoadCatPresenter.ErrorMessages.loadingError)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(networkErrorStub)
        }
    }
    
    func test_cat_provider_image_load_error() {
        let catLoadStubOK = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let imgLoadErrorStub = self.prepeareStubServerErrorForImageRequest()
        
        let loadingCatStateIdentifier = "Loading state"
        let loadCatFinishedStateIdentifier = "Load cat finished"
        let loadImageFinishedStateIdentifier = "Load image finished"
        
        let expectationLoadingState = self.expectation(description: loadingCatStateIdentifier)
        let expectationLoadFinishedState = self.expectation(description: loadCatFinishedStateIdentifier)
        let expectationLoadImageErrorState = self.expectation(description: loadImageFinishedStateIdentifier)
        
        var expectationsList = [expectationLoadingState, expectationLoadFinishedState, expectationLoadImageErrorState]
        
        presenter.updateUICallback = { () -> Void in
            guard let expectation = expectationsList.first else {
                XCTAssertNotNil(expectationsList.first)
                return
            }
            expectationsList.removeFirst()
            
            if expectation.description == loadingCatStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == loadCatFinishedStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertNotEqual(self.view.imageTitle!, LoadCatPresenter.ErrorMessages.loadingError)
                XCTAssertNotEqual(self.view.imageTitle!, LoadCatPresenter.ErrorMessages.cancelled)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == loadImageFinishedStateIdentifier {
                XCTAssertFalse(self.view.isLoading)
                XCTAssertEqual(self.view.imageTitle!, LoadCatPresenter.ErrorMessages.loadingError)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(imgLoadErrorStub)
            self.removeStub(catLoadStubOK)
        }
    }
    
    func test_cat_provider_image_load_ok() {
        
        let requestCatOK = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let requestImageOK = self.prepeareStubForSuccessImageLoadRequest()
        
        let loadingCatStateIdentifier = "Loading Cat state"
        let loadCatFinishedStateIdentifier = "Load Cat finished"
        let loadImageFinishedIdentifier = "Load Cat image finished"
        
        let expectationLoadingState = self.expectation(description: loadingCatStateIdentifier)
        let expectationLoadFinishedState = self.expectation(description: loadCatFinishedStateIdentifier)
        let expectationLoadImageFinishedState = self.expectation(description: loadImageFinishedIdentifier)
        
        var expectationsList = [expectationLoadingState, expectationLoadFinishedState, expectationLoadImageFinishedState]
        
        presenter.updateUICallback = { () -> Void in
            guard let expectation = expectationsList.first else {
                XCTAssertNotNil(expectationsList.first)
                return
            }
            expectationsList.removeFirst()
            
            if expectation.description == loadingCatStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == loadCatFinishedStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertEqual(self.view.imageTitle!, ImageFileExtensions.stubImageUrl)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
            else if expectation.description == loadImageFinishedIdentifier {
                XCTAssertFalse(self.view.isLoading)
                XCTAssertEqual(self.view.imageTitle!, ImageFileExtensions.stubImageUrl)
                XCTAssertNotNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(requestCatOK)
            self.removeStub(requestImageOK)
        }
    }
    
    func test_cat_load_cancelled() {
        let requestCatOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let reqeustImageOkStub = self.prepeareStubForSuccessImageLoadRequest()
        
        let loadingCatStateIdentifier = "Loading Cat"
        let loadCatCancelledStateIdentifier = "Loading Cat OK"
        
        var expectations = [
            self.expectation(description: loadingCatStateIdentifier),
            self.expectation(description: loadCatCancelledStateIdentifier),
        ]
        
        presenter.updateUICallback = {
            
            guard let expectation = expectations.first else {
                XCTAssertNil(expectations.first)
                return
            }
            expectations.removeFirst()
            
            if expectation.description == loadingCatStateIdentifier {
                XCTAssertTrue(self.view.isLoading)
                XCTAssertNil(self.view.imageTitle)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.presenter.cancel()
                })
            }
            else if expectation.description == loadCatCancelledStateIdentifier {
                XCTAssertFalse(self.view.isLoading)
                XCTAssertEqual(self.view.imageTitle!, LoadCatPresenter.ErrorMessages.cancelled)
                XCTAssertNil(self.view.image)
                
                expectation.fulfill()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(requestCatOkStub)
            self.removeStub(reqeustImageOkStub)
        }
    }
    
    func test_edit_cat() {
        
        let requestCatOkStub = self.prepeareStubLoadJsonOK(catProvider: catProvider)
        let reqeustImageOkStub = self.prepeareStubForSuccessImageLoadRequest()
        
        let expectation = self.expectation(description: "next presenter")
        let showEdidScreenExpectation = self.expectation(description: "Did call edit")
        
        view.didCallEditScene = { presenter in
            XCTAssertTrue(presenter is EditCatPresenterProtocol)
            showEdidScreenExpectation.fulfill()
        }
        
        presenter.updateUICallback = {
            if !self.view.isLoading {
                expectation.fulfill()
                self.presenter.editCat()
            }
        }
        
        presenter.load()
        
        self.waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error)
            
            self.removeStub(requestCatOkStub)
            self.removeStub(reqeustImageOkStub)
        }
    }
    
}
