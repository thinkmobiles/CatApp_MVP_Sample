//
//  CatPresenter.swift
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

import Foundation
import UIKit

class LoadCatPresenter: LoadCatPresenterProtocol, EditCatPresenterDelegate {
    
    //
    // LoadCatPresenterProtocol
    //
    var catProvider: CatProvider!
    
    //
    // Internal state
    //
    var currentCat: Cat?
    weak var view: LoadCatViewProtocol!
    
    //
    // View state
    //
    private var isLoading: Bool
    private var image: Data?
    private var imageTitle: String?
    
    init() {
        isLoading = false
        image = nil
        imageTitle = nil
    }
    
    func installView(_ view: View) {
        self.view = view as! LoadCatViewProtocol
    }

    func load() {
        
        guard !isLoading else { return }
        
        isLoading = true
        image = nil
        imageTitle = nil
        
        updateUI()
        loadCat()
    }
    
    func cancel() {
        
        if catProvider.isLoading {
            catProvider.cancel()
        } else {
            currentCat?.cancel()
        }
    }
    
    func updateUI() {
        view.updateLoadingState(isLoading)
        view.updateTitle(imageTitle)
        view.updateImage(image)
    }
    
    func edit() {
        let image = UIImage(data: self.image!)
        let editCatPresenter = EditCatPresenter()
        editCatPresenter.delegate = self
        editCatPresenter.image = image!
        
        view.showEditScene(withPresenter: editCatPresenter)
    }
    
    func loadCat() {
        catProvider.createNewCat { [weak self] (cat, success, catProviderError) in
            guard let strongself = self else { return }
            
            if success {
                strongself.currentCat = cat
                strongself.imageTitle = cat!.imageURL.absoluteString
                
                cat?.loadImage(complation: { (image, success, error) in
                    guard let strongself = self else { return }
                    
                    if success {
                        strongself.image = image
                    } else {
                        if CatLoadingError.cancelled == error! {
                            strongself.imageTitle = ErrorMessages.cancelled
                        } else {
                            strongself.imageTitle = ErrorMessages.loadingError
                        }
                    }
                    strongself.isLoading = false
                    strongself.updateUI()
                })
            } else {
                strongself.isLoading = false
                strongself.image = nil
                
                if CatLoadingError.cancelled == catProviderError! {
                    strongself.imageTitle = ErrorMessages.cancelled
                } else {
                    strongself.imageTitle = ErrorMessages.loadingError
                }
            }
            strongself.updateUI()
        }
    }
    
    // MARK: EditCatPresenterDelegate
    
    func finished() {
        view.finishedEdit()
    }
}

// MARK: Constants

extension LoadCatPresenter {
    public enum ErrorMessages {
        static let loadingError = "LoadingError"
        static let cancelled = "Cancelled"
    }
}
