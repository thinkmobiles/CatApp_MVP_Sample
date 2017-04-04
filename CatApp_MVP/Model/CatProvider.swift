//
//  CatProvider.swift
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

public enum CatLoadingError: Error {
    case networkError
    case serverError
    case formatError
    case busy
    case unknownError
    case cancelled
}

public class CatProvider {
    
    public let providerURL: NSURL
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    public private(set) var isLoading: Bool
    
    public init() {
        providerURL = NSURL(string: Constants.providerUrl)!
        session = URLSession(configuration: URLSessionConfiguration.default)
        isLoading = false
    }
    
    public func createNewCat(complation: @escaping(_ cat: Cat?, _ success: Bool, _ error: CatLoadingError?) -> Void) {
        
        guard !isLoading else {
            complation(nil, false, CatLoadingError.busy)
            return
        }
        
        isLoading = true
        
        dataTask = session.dataTask(with: providerURL as URL, completionHandler: { (data, response, dataTaskError) in
            var cat: Cat?
            var LoadError: CatLoadingError?
            
            do {
                guard self.dataTask?.state != .canceling else {
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
                guard let data = data else {
                    throw CatLoadingError.formatError
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    throw CatLoadingError.formatError
                }
                guard let catUrlString = json?["file"] as? String, let catURL = NSURL(string: catUrlString) else {
                    throw CatLoadingError.formatError
                }
                cat = Cat(imageURL: catURL)
              }
            catch let exception as CatLoadingError {
                LoadError = exception
            }
            catch _ {
                LoadError = CatLoadingError.unknownError
            }
            
            let finish = { () -> Void in
                self.isLoading = false
                let loadOK = nil == LoadError
                complation(cat, loadOK, LoadError)
            }
            
            if !Thread.isMainThread {
                DispatchQueue.main.async(execute: { 
                    finish()
                })
            } else {
                finish()
            }
        })
        
        dataTask?.resume()
    }
    
    public func cancel() {
        dataTask?.cancel()
    }
}

extension CatProvider {
    
    enum Constants {
        static let providerUrl = "http://random.cat/meow"
    }
}
