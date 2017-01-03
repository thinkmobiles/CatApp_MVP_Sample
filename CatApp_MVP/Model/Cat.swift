//
//  Cat.swift
//  CatApp_MVP
//
//  Created by Robert on 1/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import UIKit

public class Cat {
    
    public let date: NSDate
    public let imageURL: NSURL
    public private(set) var image: UIImage?
    private var downloadTask: URLSessionDownloadTask?
    
    public init(imageURL: NSURL) {
        self.date = NSDate()
        self.imageURL = imageURL
        self.image = nil
    }
    
    public func loadImage(complation: @escaping (_ success: Bool, _ image: UIImage?) -> Void) {
        downloadTask = URLSession.shared.downloadTask(with: imageURL as URL) { (url, response, error) in
            
            var downloadOK = true
            
            do {
                guard error == nil else {
                    throw CatDownloadError.networkError
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw CatDownloadError.serverError
                }
                guard let url = url else {
                    throw CatDownloadError.formatError
                }
                self.image = UIImage(contentsOfFile: url.path)
                guard self.image != nil else {
                    throw CatDownloadError.formatError
                }
            } catch _ {
                downloadOK = false
            }
            
            let finish = { () -> Void in
                complation(downloadOK, self.image)
            }
            
            if !Thread.isMainThread {
                DispatchQueue.main.async(execute: { 
                    finish()
                })
            } else {
                finish()
            }
            
        }
        downloadTask?.resume()
    }
    
    public func cancel() {
        downloadTask?.cancel()
    }
}

extension Cat {
    enum CatDownloadError: Error {
        case networkError
        case serverError
        case formatError
    }
}
