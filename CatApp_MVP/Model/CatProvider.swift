//
//  CatProvider.swift
//  CatApp_MVP
//
//  Created by Robert on 1/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import Foundation
import UIKit

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
    
    public func createNewCat(complation: @escaping(_ cat: Cat?, _ success: Bool) -> Void) {
        
        guard !isLoading else {
            complation(nil, false)
            return
        }
        
        isLoading = true
        
        dataTask = session.dataTask(with: providerURL as URL, completionHandler: { (data, response, error) in
            var loadOK = true
            var cat: Cat?
            
            do {
                guard error == nil else {
                    throw CatInitializationError.networkError
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    throw CatInitializationError.serverError
                }
                guard let data = data else {
                    throw CatInitializationError.dataFormatError
                }
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
                    throw CatInitializationError.dataFormatError
                }
                guard let catUrlString = json?["file"] as? String, let catURL = NSURL(string: catUrlString) else {
                    throw CatInitializationError.dataFormatError
                }
                cat = Cat(imageURL: catURL)
              } catch _ {
                loadOK = false
            }
            
            let finish = { () -> Void in
                self.isLoading = false
                complation(cat, loadOK)
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
    
    enum CatInitializationError: Error {
        case networkError
        case serverError
        case dataFormatError
    }
}
