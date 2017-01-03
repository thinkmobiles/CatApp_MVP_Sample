//
//  AppDelegate.swift
//  CatApp_MVP
//
//  Created by Robert on 1/1/17.
//  Copyright © 2017 Robert. All rights reserved.
//

import UIKit
import OHHTTPStubs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var catProvider: CatProvider?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
     
        self.catProvider = CatProvider()
        guard let catProvider = catProvider else { return false }
        
        let view = window?.rootViewController as! CatViewProtocol
        let presenter = CatPresenter(view: view, catProvider: catProvider)
        view.setPresenter(presenter)
        
        return true
    }
}

