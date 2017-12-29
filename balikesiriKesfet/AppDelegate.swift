//
//  AppDelegate.swift
//  balikesiriKesfet
//
//  Created by xloop on 30/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import GLKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseApp.configure()
        
        //create the notificationCenter
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            // Enable or disable features based on authorization
            
        }
        application.registerForRemoteNotifications()
        
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let isHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: options[.sourceApplication] as! String!, annotation: options[.annotation])
        return isHandled
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        //print("\n\nToken is: http://app.balikesirikesfet.com/token_add&token="+token+"\n\n")
        let fbTokenURL = "http://app.balikesirikesfet.com/token_add&token="+token
        let urlRequest = URLRequest(url: URL(string: fbTokenURL)!)
        
        let tokenTask = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            //print("\n\nSTARTRES")
            //print(response!)
            //print("ENDRES\n\n")
        }
        
        tokenTask.resume()
        
        Messaging.messaging().subscribe(toTopic: "xloop")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
        if UIApplication.shared.applicationState == .active { // In iOS 10 if app is in foreground do nothing.
            completionHandler([.alert, .badge, .sound])
        } else { // If app is not active you can show banner, sound and badge.
            completionHandler([.alert, .badge, .sound])
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if ( application.applicationState == .inactive || application.applicationState == .background){
            
            //handle tapping on push notification and here you can open needed controller
        }
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
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

