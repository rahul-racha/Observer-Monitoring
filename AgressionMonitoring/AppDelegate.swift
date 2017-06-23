//
//  AppDelegate.swift
//  AgressionMonitoring
//
//  Created by rahul rachamalla on 6/5/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForPushNotifications(application: application)
        
        Manager.patientDetails = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let _ = self.window?.rootViewController as! LoginViewController
        UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let splitViewController =  storyboard.instantiateViewController(withIdentifier: "splitViewController") as! UISplitViewController//self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let masterViewController = leftNavController.topViewController as! PatientRootTableViewController
        
        let rightNavController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = rightNavController.topViewController as! DetailViewController
        
//        if (Manager.patientDetails != nil && Manager.patientDetails!.count > 0) {
//            detailViewController.patient = Manager.patientDetails![0]//masterViewController.patientDetails[0]
//        } else {
//            //firstPatient[""] =
//        }
        
        //masterViewController.delegatePatient = detailViewController//storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController

        
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        return true
    }
    
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in }
            application.registerForRemoteNotifications()
        } else if #available(iOS 9.0, *) {
            // Fallback on earlier versions
            //let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            //application.registerUserNotificationSettings(notificationSettings)
            //application.registerForRemoteNotifications()
            
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else if #available(iOS 8.0, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
    
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        Manager.deviceId = deviceTokenString
        print(deviceTokenString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        //print("Oops! \(error)")
        //if code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        //} else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        //}
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //print(userInfo)
        let data = userInfo["aps"] as! [String : Any]
        let patient: [String: Any] = data["data"] as! [String : Any]
        if (Manager.triggerNotifications == true) {
            displayPatient(patient: patient)
        }
        completionHandler(UIBackgroundFetchResult.newData);
    }
    
    func displayPatient(patient: [String: Any]) {
        Manager.reloadAllCells = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let splitViewController =  storyboard.instantiateViewController(withIdentifier: "splitViewController") as! UISplitViewController//self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let patientRootVC = leftNavController.topViewController as! PatientRootTableViewController
        patientRootVC.reloadIndexPath(patient: patient)
        //let patientRootVC = storyboard.instantiateViewController(withIdentifier: "PatientRootTableViewController") as! PatientRootTableViewController
        //UIApplication.shared.keyWindow?.rootViewController = patientRootVC
        //storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController//ViewController()
        //vc.reloadIndexPath(patient:patient)
        Manager.reloadAllCells = true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

