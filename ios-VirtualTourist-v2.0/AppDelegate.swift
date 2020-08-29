//
//  AppDelegate.swift
//  ios-VirtualTourist
//
//  Created by Abdullah Khayat on 8/26/20.
//  Copyright © 2020 Abdullah Khayat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let dataController2 = DataController(modelName: "Model")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        dataController2.load()
        checkIfFirstLaunch()
        
        return true
    }
    
    func checkIfFirstLaunch() {
        
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            print("App has launched before")
        } else {
            print("This is the first launch ever!")
            UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        save()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        save()
    }
    
    func save() {
        try? dataController2.viewContext.save()
    }

}
