//
//  Cat.swift
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

public class Cat {
    
    public let date: NSDate
    public let imageURL: NSURL
    public private(set) var image: Data?
    private var downloadTask: URLSessionDownloadTask?
    
    public init(imageURL: NSURL) {
        self.date = NSDate()
        self.imageURL = imageURL
        self.image = nil
    }
    
    public func loadImage(complation: @escaping (_ image: Data?, _ success: Bool, _ error: CatLoadingError?) -> Void) {
        downloadTask = URLSession.shared.downloadTask(with: imageURL as URL) { (url, response, dataTaskError) in
            
            var downloadError: CatLoadingError?
            
            do {
                guard self.downloadTask?.state != .canceling else {
                    throw CatLoadingError.cancelled
                }
                guard dataTaskError == nil else {
                    guard let dataTaskNSError = dataTaskError as? NSError else {
                        throw CatLoadingError.networkError
                    }
                    guard dataTaskNSError.domain != NSURLErrorDomain && dataTaskNSError.code != NSURLErrorCancelled else {
                        throw CatLoadingError.cancelled
                    }
                    throw CatLoadingError.networkError
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw CatLoadingError.serverError
                }
                guard let url = url else {
                    throw CatLoadingError.formatError
                }
                self.image = try? Data(contentsOf: url)
                guard self.image != nil else {
                    throw CatLoadingError.formatError
                }
            } catch let downloadException as CatLoadingError {
                downloadError = downloadException
            } catch _ {
                downloadError = CatLoadingError.unknownError
            }
            
            let finish = { () -> Void in
                complation(self.image, nil == downloadError, downloadError)
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
