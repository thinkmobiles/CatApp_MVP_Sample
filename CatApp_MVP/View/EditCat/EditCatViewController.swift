//
//  EditCatViewController.swift
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

class EditCatViewController: UIViewController, EditCatViewProtocol {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //
    // EditCatViewProtocol variables
    //
    var presenter: EditCatPresenterProtocol!
    var imageList: [UIImage]! {
        didSet {
            didSetImageList()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateView()
    }
    
    @IBAction func actCancel(_ sender: UIButton) {
        presenter.finishEditing()
    }
    
    @IBAction func actSave(_ sender: UIButton) {
        presenter.saveImage()
    }
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter as! EditCatPresenterProtocol
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
    
    func updateImage(_ image: UIImage) {
        imageView.image = image
    }
    
    func imageListUpdateImage(_ image: UIImage, at index: Int) {
        imageList[index] = image
        
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func updateProcessingState(_ processingState: Bool) {
        saveButton.isEnabled = !processingState
        if processingState && activityIndicator.isHidden {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else if !processingState && !activityIndicator.isHidden {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
        }
    }
    
    func showMessage(_ message: String) {
        let appName = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String
        let alertController = UIAlertController(title: appName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            self.presenter.finishEditing()
        }
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func didSetImageList() {
        self.collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension EditCatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellId, for: indexPath) as! ImageFilterCell
        cell.image = imageList[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
}

// MARK: UICollectionViewDelegate

extension EditCatViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.selectedImageAtIndex(indexPath.item)
    }
}

extension EditCatViewController {
    enum Constants {
        static let cellId = "ImageFilterCell"
    }
}
