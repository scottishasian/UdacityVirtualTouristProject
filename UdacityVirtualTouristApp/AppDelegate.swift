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
    let dataController = DataManager(modelName: "Virtual_Tourist_Model")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        dataController.load()
        //To get to the inital view.
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewCOntroller = navigationController.topViewController as! MapViewController
        //This will inject the data controller dependency into the notebooks list VM. Now it can load safe data into the app.
        mapViewCOntroller.dataController = dataController
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveViewContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveViewContext()
    }
    
    //Helper
    func saveViewContext() {
        //For saving before the app it terminated or backgrounded.
        try? dataController.viewContext.save()
    }


}

