//
//  PresenterTest.swift
//  CatApp_MVP
//
//  Created by Robert on 1/2/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import XCTest

@testable import CatApp_MVP

class MockUI: CatViewProtocol {
    
    private var presenter: CatPresenterProtocol?
    
    var loadButtonEnabled: Bool
    var cancelButtonEnabled: Bool
    var loadingIndicatorVisible: Bool
    var imageURL: String?
    var image: UIImage?
    
    init() {
        loadButtonEnabled = true
        cancelButtonEnabled = true
        loadingIndicatorVisible = true
        imageURL = nil
        image = nil
    }
    
    func resetState() {
        loadButtonEnabled = true
        cancelButtonEnabled = true
        loadingIndicatorVisible = true
        imageURL = nil
        image = nil
    }
    
    func setLoadButtonEnabled(_ enabled: Bool) {
        loadButtonEnabled = enabled
    }
    
    func setCancelButtonEnabled(_ enabled: Bool) {
        cancelButtonEnabled = enabled
    }
    
    func setLoadIndicatorVisible(_ visible: Bool) {
        loadingIndicatorVisible = visible
    }
    
    func setImageURL(_ url: String?) {
        imageURL = url
    }
    
    func setImage(_ img : UIImage?) {
        image = img
    }
    
    func setPresenter(_ presenter: CatPresenterProtocol?) {
        self.presenter = presenter
        self.presenter?.updateUI()
    }
    
    func getPresenter() -> CatPresenterProtocol? {
        return presenter
    }
}

class PresenterTest: XCTestCase {
    
    var catProvider: CatProvider!
    var presenter: CatPresenterProtocol!
    var view: CatViewProtocol!
    
    override func setUp() {
        super.setUp()
        
        catProvider = CatProvider()
        view = MockUI()
        presenter = CatPresenter(view: view, catProvider: catProvider)
        view.setPresenter(presenter)
    }
}

// MARK: Cat provider level cases

extension PresenterTest {
    
//    func test_cat_provider_network_error() {
//        let networkErrorStub = self.prepeareStubServerErrorFor(catProvider: catProvider)
//        let expectation = self.expectation(forNotification: "didChangeImageURL", object: nil) { (notification) -> Bool in
//            
//        }
//        
//        presenter.load(sender: UIButton())
//        
//        self.waitForExpectations(timeout: 10) { (error) in
//            XCTAssertNil(error)
//        }
//        
//        removeStub(networkErrorStub)
//        
//    }
    
}
