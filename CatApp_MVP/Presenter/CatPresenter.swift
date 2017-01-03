//
//  CatPresenter.swift
//  CatApp_MVP
//
//  Created by Robert on 1/2/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import Foundation
import UIKit

protocol CatViewProtocol {
    //var loadButtonEnabled: Bool { get set }
    func setLoadButtonEnabled(_ enabled: Bool)
    func setCancelButtonEnabled(_ enabled: Bool)
    func setLoadIndicatorVisible(_ visible: Bool)
    func setImageURL(_ url: String?)
    func setImage(_ image : UIImage?)
    
    func setPresenter(_ presenter: CatPresenterProtocol?)
    func getPresenter() -> CatPresenterProtocol?
}

protocol CatPresenterProtocol {
    func load(sender:UIButton) -> Void
    func cancel(sender:UIButton) -> Void
    func updateUI()
}

class CatPresenterModel {
    var isLoadButtonEnabled: Bool
    var isCancelButtonEnabled: Bool
    var isLoadIndicatorVisible: Bool
    var image: UIImage?
    var imageURL: String?
    var isCanceling: Bool
    
    init() {
        isLoadButtonEnabled = true
        isCancelButtonEnabled = false
        isLoadIndicatorVisible = false
        isCanceling = false
        image = nil
        imageURL = nil
    }
    
    func configureToLoadingState() {
        isLoadButtonEnabled = false
        isCancelButtonEnabled = true
        isLoadIndicatorVisible = true
        isCanceling = false
        image = nil
        imageURL = nil
    }
    
    func updateStateWith(cat: Cat) {
        isLoadButtonEnabled = false
        isCancelButtonEnabled = true
        isLoadIndicatorVisible = true
        isCanceling = false
        imageURL = cat.imageURL.absoluteString
        image = cat.image
    }
    
    func configureToFinishStateWith(cat: Cat?, cancelled: Bool) {
        isLoadButtonEnabled = true
        isCancelButtonEnabled = false
        isLoadIndicatorVisible = false
        
        if !cancelled {
            if cat != nil {
                imageURL = cat?.imageURL.absoluteString ?? ""
            } else {
                imageURL = CatPresenter.ErrorMessages.loadingError
            }
        } else {
            imageURL = CatPresenter.ErrorMessages.cancelled
        }
        
        image = cancelled ? nil : cat?.image
    }
}

public class CatPresenter {
    let catPresenterModel: CatPresenterModel
    let catProvider: CatProvider
    let view: CatViewProtocol
    var currentCat: Cat?
    var cancelling: Bool
    
    init(view: CatViewProtocol, catProvider: CatProvider) {
        catPresenterModel = CatPresenterModel()
        self.catProvider = catProvider
        self.view = view
        cancelling = false
    }
    
    func updateUIWith(catPresenterModel: CatPresenterModel) {
        view.setLoadButtonEnabled(catPresenterModel.isLoadButtonEnabled)
        view.setCancelButtonEnabled(catPresenterModel.isCancelButtonEnabled)
        view.setLoadIndicatorVisible(catPresenterModel.isLoadIndicatorVisible)
        view.setImageURL(catPresenterModel.imageURL)
        view.setImage(catPresenterModel.image)
    }
}

public extension CatPresenter {
    public enum ErrorMessages {
        static let loadingError = "LoadingError"
        static let cancelled = "Cancelled"
    }
}

extension CatPresenter: CatPresenterProtocol {
    func cancel(sender: UIButton) {
        cancelling = true
        
        if catProvider.isLoading {
            catProvider.cancel()
        } else {
            currentCat?.cancel()
        }
    }

    func load(sender: UIButton) {
        catPresenterModel.configureToLoadingState()
        updateUIWith(catPresenterModel: catPresenterModel)
        
        catProvider.createNewCat { (cat, success) in
            self.currentCat = cat
            self.catPresenterModel.updateStateWith(cat: self.currentCat!)
            
            if success {
                cat?.loadImage(complation: { (success, image) in
                    self.currentCat = cat
                    if success {
                        self.catPresenterModel.configureToFinishStateWith(cat: cat, cancelled: self.cancelling)
                    } else {
                        self.catPresenterModel.configureToFinishStateWith(cat: cat, cancelled: self.cancelling)
                        self.cancelling = false
                    }
                    self.updateUIWith(catPresenterModel: self.catPresenterModel)
                })
            } else {
                self.catPresenterModel.configureToFinishStateWith(cat: cat, cancelled: self.cancelling)
                self.cancelling = false
            }
            self.updateUIWith(catPresenterModel: self.catPresenterModel)
        }
    }
    
    func updateUI() {
        updateUIWith(catPresenterModel: catPresenterModel)
    }
}
