//
//  EditCatPresenter.swift
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

import UIKit
import Photos

protocol EditCatPresenterDelegate: class {
    func finished()
}

class EditCatPresenter: EditCatPresenterProtocol {
    
    //
    // EditCatPresenterProtocol variables
    //
    var image: UIImage! {
        didSet{
            processedCatImage = image
        }
    }
    weak var delegate: EditCatPresenterDelegate!
    
    //
    // View state
    //
    private var isProcessing: Bool
    private var processedCatImage: UIImage!
    lazy private var imageList: [UIImage]! = self.initiateSampleImageList()
    
    //
    // Internal state
    //
    private weak var view: EditCatViewProtocol!
    private var filterList: [CIFilter]!
    private let catImageFilterOperationQueue: OperationQueue
    private let filterListOperationQueue: OperationQueue
    
    required init() {
        isProcessing = false
        
        filterListOperationQueue = OperationQueue()
        filterListOperationQueue.maxConcurrentOperationCount = Constants.maxConcurentOperationsCount
        
        catImageFilterOperationQueue = OperationQueue()
        catImageFilterOperationQueue.maxConcurrentOperationCount = 1
    }
    
    func installView(_ view: View) {
        self.view = view as! EditCatViewProtocol
    }
    
    func updateView() {
        view.updateProcessingState(isProcessing)
        view.updateImage(image)
        view.imageList = imageList
        createFilteredImages()
    }
    
    func selectedImageAtIndex(_ index: Int) {
        isProcessing = true
        view.updateProcessingState(isProcessing)
        filterImage(image, withFilter: filterList[index])
    }
    
    func saveImage() {
        saveImageToPhotosAlbum(self.processedCatImage)
    }
 
    func finishEditing() {
        filterListOperationQueue.cancelAllOperations()
        catImageFilterOperationQueue.cancelAllOperations()
        delegate?.finished()
    }
    
    func createFilteredImages() {
        filterList = Constants.filterNames.map { filterName -> CIFilter in
            let filter = CIFilter(name: filterName)!
            filter.setDefaults()
            return filter
        }
        processImageList()
    }
    
    func initiateSampleImageList() -> [UIImage] {
        let imageListItem = UIImage(named: Constants.placeholderImageName)!
        let imageListCount = Constants.filterNames.count
        return Array(repeating: imageListItem, count: imageListCount)
    }
    
    func filterImage(_ image: UIImage, withFilter filter: CIFilter) {
        
        catImageFilterOperationQueue.cancelAllOperations()
        
        let newOperation = FilterOperation(filter: filter, image: image)
        newOperation.completionBlock = { [weak self, weak operation = newOperation] in
            guard let strongself = self, let operation = operation else { return }
            guard !operation.isCancelled else { return }
            
            DispatchQueue.main.async {
                strongself.isProcessing = false
                strongself.processedCatImage = operation.outputImage!
                strongself.view.updateImage(strongself.processedCatImage)
                strongself.view.updateProcessingState(strongself.isProcessing)
            }
        }
        catImageFilterOperationQueue.addOperation(newOperation)
    }
    
    func saveImageToPhotosAlbum(_ image: UIImage) {
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(){ [weak self] _ in
                self?.saveImageToPhotosAlbum(image)
            }
            
        case .restricted:
            self.view.showMessage(Constants.photoLibraryAccessRestrictedMessage)
            
        case .denied:
            self.view.showMessage(Constants.photoLibraryAccessDeniedMessage)
            
        case .authorized:
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { [weak self] (success, error) in
                guard let strongself = self else { return }
                
                if !success {
                    strongself.view.showMessage(Constants.saveImageFailedMessage)
                } else {
                    strongself.view.showMessage(Constants.saveImageSuccessMessage)
                }
            }
        }
    }
    
    func processImageList() {
        let operations = filterList.map { filter -> FilterOperation in
            
            let index = filterList.index(of: filter)!
            let image = imageList[index]
            let operation = FilterOperation(filter: filter, image: image)
            
            operation.completionBlock = { [weak self, weak weakOperation = operation] in
                guard let img = weakOperation?.outputImage else {
                    return
                }
                DispatchQueue.main.async {
                    self?.imageList[index] = img
                    self?.view.imageListUpdateImage(img, at: index)
                }
            }
            return operation
            
        }
        filterListOperationQueue.addOperations(operations, waitUntilFinished: false)
    }
}

extension EditCatPresenter {
    enum Constants {
        static let filterNames = ["CIPhotoEffectMono", "CISepiaTone", "CIColorInvert", "CIPhotoEffectChrome",
                                  "CIPhotoEffectTransfer", "CIPhotoEffectProcess", "CIPhotoEffectNoir",
                                  "CIPhotoEffectInstant", "CIPhotoEffectFade"]
        static let maxConcurentOperationsCount = 5
        static let placeholderImageName = "CatFace"
        static let photoLibraryAccessRestrictedMessage = "Access to photos library restricted"
        static let photoLibraryAccessDeniedMessage = "Access to photos denied"
        static let saveImageFailedMessage = "Failed to save image"
        static let saveImageSuccessMessage = "Saving image complete"
    }
}
