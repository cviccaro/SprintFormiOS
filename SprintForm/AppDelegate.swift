//
//  AppDelegate.swift
//  SprintForm
//
//  Created by Chris Viccaro on 9/26/17.
//  Copyright © 2017 JP Enterprises. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataManager: DataManager = DataManager()
    var trackingID: String = ""
    var sources = [
        //"jp" : "JP Devices",
        "102": "Store 102",
        "103": "Store 103",
        "112": "Store 112",
        "277": "Store 277",
        "341": "Store 341",
        "353": "Store 353",
        "356": "Store 356",
        "460": "Store 460",
        "461": "Store 461",
        "686": "Store 686",
        "693": "Store 693",
        "756": "Store 756",
        "762": "Store 762",
        "857": "Store 857",
        "874": "Store 874",
        "985": "Store 985",
        "986": "Store 986",
        "1445": "Store 1445",
        "2093": "Store 2093",
        "4935": "Store 4935",
        "6582": "Store 6582",
        "6583": "Store 6583",
        "6584": "Store 6584",
        "6588": "Store 6588",
        "6596": "Store 6596",
        "6601": "Store 6601",
        "7436": "Store 7436",
        "7438": "Store 7438",
        "7439": "Store 7439",
        "7440": "Store 7440",
        "7444": "Store 7444",
        "7455": "Store 7455",
        "7968": "Store 7968",
        "anna": "Anna"
    ]

    var sourceMap: [String] = [
        //"jp",
        "102",
        "103",
        "112",
        "277",
        "341",
        "353",
        "356",
        "460",
        "461",
        "686",
        "693",
        "756",
        "762",
        "857",
        "874",
        "985",
        "986",
        "1445",
        "2093",
        "4935",
        "6582",
        "6583",
        "6584",
        "6588",
        "6596",
        "6601",
        "7436",
        "7438",
        "7439",
        "7440",
        "7444",
        "7455",
        "7968",
        "anna"
    ],

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        self.dataManager.stopTimer()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface
        self.dataManager.startTimer()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SprintForm")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

