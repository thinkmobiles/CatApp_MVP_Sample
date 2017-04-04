//
//  ViewController.swift
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

class LoadCatViewController: UIViewController, LoadCatViewProtocol {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var loadButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var imageTitleLabel: UILabel!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    var presenter: LoadCatPresenterProtocol!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.updateUI()
    }
    
    @IBAction func actLoad(_ sender: UIBarButtonItem) {
        presenter.load()
    }
    
    @IBAction func actCancel(_ sender: UIBarButtonItem) {
        presenter.cancel()
    }
    
    @IBAction func actEdit(_ sender: UIBarButtonItem) {
        loadButton.isEnabled = false
        editCat()
    }
    
    func setPresenter(_ presenter: Presenter) {
        self.presenter = presenter as! LoadCatPresenterProtocol
    }
    
    func getPresenter() -> Presenter {
        return presenter
    }
    
    func updateLoadingState(_ loadingState: Bool) {
        loadButton.isEnabled = !loadingState
        cancelButton.isEnabled = loadingState
        
        if loadingState && loadingIndicator.isHidden {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else if !loadingState && !loadingIndicator.isHidden {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    func updateTitle(_ imageTitle: String?) {
        imageTitleLabel.text = imageTitle
    }
    
    func updateImage(_ image: Data?) {
        
        if let image = image {
            let uiimage = UIImage(data: image)
            imageView.image = uiimage
            editButton.isEnabled = true
        } else {
            imageView.image = nil
            editButton.isEnabled = false
        }
    }
    
    func finishedEdit() {
        loadButton.isEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    func editCat() {
        presenter.edit()
    }
    
    func showEditScene(withPresenter presenter: Presenter) {
        let nextViewController = storyboard!.instantiateViewController(withIdentifier: Constants.editCatViewControllerStoryboardId) as! View
        presenter.installView(nextViewController)
        nextViewController.setPresenter(presenter)
        present(nextViewController as! UIViewController, animated: true, completion: nil)
    }
}

extension LoadCatViewController {
    enum Constants {
        static let editCatViewControllerStoryboardId = "EditCatViewController"
    }
}
