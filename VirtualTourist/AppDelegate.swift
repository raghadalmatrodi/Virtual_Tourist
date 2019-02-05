//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Raghad Almatrodi on 1/29/19.
//  Copyright © 2019 raghad almatrodi. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       CoreData.shared.load()
        return true
    }
    
}
