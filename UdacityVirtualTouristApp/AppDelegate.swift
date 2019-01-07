//
//  AppDelegate.swift
//  UdacityVirtualTouristApp
//
//  Created by Kynan Song on 29/12/2018.
//  Copyright © 2018 Kynan Song. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    //Load persited data as early as possible. Needs to be the same as the data model, not the app.
    let dataManager = DataManager(modelName: "Virtual_Tourist_Model")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
    
        return true
    }

    //Removed on suggestion of review.

}

