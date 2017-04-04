//
//  TestEditCatPresenter.swift
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

typealias DidUpdateImageCallback = (_ image: UIImage, _ index: Int) -> Void
typealias DidSetImageListCallback = (_ imageList: [UIImage]) -> Void
typealias DidSetProcessingStateCallback = () -> Void
typealias DidSetCatImageCallback = () -> Void

class EditCatStubView: EditCatViewProtocol {
    
    var imageList: [UIImage]! {
        didSet {
            if let callback = setImageListCallback {
                callback(imageList)
            }
        }
    }
    
    var catImage: UIImage?
    var processing = false
    var messageToShow: String?
    var presenter: Presenter!
    
    var setImageListCallback: DidSetImageListCallback?
    var updateImageCallback: DidUpdateImageCallback?
    var setProcessingStateCallback: DidSetProcessingStateCallback?
    var setCatImageCallback: DidSetCatImageCallback?
    
    
    func imageListUpdateImage(_ image: UIImage, at index: Int) {
        imageList[index] = image
        
        if let callback = updateImageCallback {
            callback(image, index)
        }
    }
    
    func updateProcessingState(_ isProcessing: Bool) {
        processing = isProcessing
        if let callback = setProcessingStateCallback {
            callback()
        }
    }
    
    func updateImage(_ image: UIImage) {
        catImage = image
        if let callback = setCatImageCallback {
            callback()
        }
    }
    
    func showMessage(_ message: String) {
        messageToShow = message
    }
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
}

class EditCatPresenterDelegateClass: EditCatPresenterDelegate {
    func finished() {
        
    }
}

class TestEditCatPresenter: XCTestCase {
    
    var presenter: EditCatPresenterProtocol!
    var view: EditCatStubView!
    var delegate: EditCatPresenterDelegateClass!
    var testImage: UIImage!
    
    override func setUp() {
        super.setUp()
        
        view = EditCatStubView()
        delegate = EditCatPresenterDelegateClass()
        
        testImage = UIImage(named: EditCatPresenter.Constants.placeholderImageName)
        XCTAssertNotNil(testImage)
        presenter = EditCatPresenter()
        presenter.image = testImage
        presenter.delegate = delegate
        
        view.setPresenter(presenter)
        presenter.installView(view)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_configure_view() {

        /* Test how presenter configures the View */
        
        var expectationList = [XCTestExpectation]()
        
        for _ in 0..<EditCatPresenter.Constants.filterNames.count {
            expectationList.append(self.expectation(description: "initiated all images"))
        }
        
        view.updateImageCallback = { (img, index) in
            
            for i in 0..<EditCatPresenter.Constants.filterNames.count {
                guard i != index else { continue }
                
                let png1 = UIImagePNGRepresentation(self.view.imageList[i])
                let png2 = UIImagePNGRepresentation(img)
                XCTAssertNotEqual(png1, png2)
            }
            
            let expecation = expectationList.removeFirst()
            expecation.fulfill()
        }
        
        presenter.updateView()
        
        XCTAssertFalse(view.processing)
        XCTAssertEqual(UIImagePNGRepresentation(view.catImage!), UIImagePNGRepresentation(testImage))
        
        self.waitForExpectations(timeout: 20) { error in
            XCTAssertNil(error)
        }
        
        /* Test each image filters */
        
        let changeProcessingStateTrueDescription = "Change processing state true"
        let changeProcessingStateFalseDescription = "Change processing state false"
        let changeCatImageDescription = "Change cat image"
        
        for i in 0..<EditCatPresenter.Constants.filterNames.count {
            
            print("Testing image filter \(i) of \(EditCatPresenter.Constants.filterNames.count - 1)")
            
            var changedProcessingStateTrue: XCTestExpectation? = self.expectation(description: changeProcessingStateTrueDescription)
            var changeProcessingStatefalse: XCTestExpectation? = self.expectation(description: changeProcessingStateFalseDescription)
            var changedCatImage: XCTestExpectation? = self.expectation(description: changeCatImageDescription)
            
            view.setProcessingStateCallback = {
                if self.view.processing {
                    // It means :
                    // 1. chnage processingState to true never called
                    // 2. chnage processingState to false never called
                    // 3. update image never called
                    XCTAssertNotNil(changedProcessingStateTrue)
                    XCTAssertNotNil(changeProcessingStatefalse)
                    XCTAssertNotNil(changedCatImage)
                    
                    changedProcessingStateTrue!.fulfill()
                    changedProcessingStateTrue = nil
                } else {
                    // It means :
                    // 1. Chnage processingState to false called once and only once
                    // 2. Change processingState to true never called before
                    // 3. No matter if update image called or not before
                    XCTAssertNil(changedProcessingStateTrue)
                    XCTAssertNotNil(changeProcessingStatefalse)
                    
                    changeProcessingStatefalse!.fulfill()
                    changeProcessingStatefalse = nil
                }
            }
            
            view.setCatImageCallback = {
                // It means 
                // 1. Change procesisngState to false called at least once
                // 2. Set image didnt call before
                XCTAssertNil(changedProcessingStateTrue)
                XCTAssertNotNil(changedCatImage)
                
                changedCatImage!.fulfill()
                changedCatImage = nil
                
                // Check image
                let originalPNG = UIImagePNGRepresentation(self.view.imageList[i])
                let processedPNG = UIImagePNGRepresentation(self.view.catImage!)
                
                XCTAssertEqual(originalPNG, processedPNG)
            }
            
            presenter.selectedImageAtIndex(i)
            
            self.waitForExpectations(timeout: 10, handler: { (error) in
                XCTAssertNil(error)
            })
        }
        
        presenter.saveImage()
    }
    
    
}
