//
//  ViewController.swift
//  CatApp_MVP
//
//  Created by Robert on 1/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var loadButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var imageUrlLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var presenter: CatPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.updateUI()
    }
}

// MARK: CatViewProtocol

extension ViewController: CatViewProtocol {
    
//    var loadButtonEnabled: Bool {
//        get { return loadButton.isEnabled }
//        set { loadButton.isEnabled = newValue }
//    }
    
    func setLoadButtonEnabled(_ enabled: Bool) {
        loadButton.isEnabled = enabled
    }
    
    func setCancelButtonEnabled(_ enabled: Bool) {
        cancelButton.isEnabled = enabled
    }
    
    func setLoadIndicatorVisible(_ visible: Bool) {
        loadingIndicator.isHidden = !visible
        
        if visible {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }
    
    func setImageURL(_ url: String?) {
        imageUrlLabel.text = url
    }
    
    func setImage(_ image : UIImage?) {
        imageView.image = image
    }
    
    func setPresenter(_ presenter: CatPresenterProtocol?) {
        self.presenter = presenter
    }
    
    func getPresenter() -> CatPresenterProtocol? {
        return presenter
    }
}

// MARK: IBActions

extension ViewController {
    @IBAction func actLoad(_ sender: UIButton) {
        presenter?.load(sender: sender)
    }
    
    @IBAction func actCancel(_ sender: UIButton) {
        presenter?.cancel(sender: sender)
    }
}
