//
//  AppDelegate.swift
//  balikesiriKesfet
//
//  Created by xloop on 30/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import GLKit
import UserNotifications
import Firebase
import FirebaseMessaging
import FBSDKShareKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var currentLocation=CLLocation()
    var lastLocation = CLLocation()
    var locationManager=CLLocationManager()
    let prefs:UserDefaults = UserDefaults.standard
    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    var backgroundTaskTimer:Timer! = Timer()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //FBSDKLoginManager.renewSystemCredentials { (result:ACAccountCredentialRenewResult, error:NSError!) -> Void in }
        
        FirebaseApp.configure()
        
        //create the notificationCenter
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            // Enable or disable features based on authorization
            
        }
        application.registerForRemoteNotifications()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        self.setupLocationManager()

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
    
    //Background fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       let sessionConfig = URLSessionConfiguration.default
        self.setupLocationManager()
        
        
        var haveData = false
        self.locationManager.startUpdatingLocation()
        let urlString = "http://app.balikesirikesfet.com/json_distance?lat=\(self.currentLocation.coordinate.latitude)&lng=\(self.currentLocation.coordinate.longitude)&dis=2"
        self.scheduleLocal(title: "url", description: "\(urlString)")
        let urlRequest = URLRequest(url: URL(string: urlString)!)

        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            } else {
                haveData = true

            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]


            } catch let error {
                print(error)
            }
        }
        task.resume()
        if(haveData){
            self.scheduleLocal(title: "Fetch update", description: "Fetched")
            completionHandler(UIBackgroundFetchResult.newData)
        } else {
            self.scheduleLocal(title: "Fetch update", description: "No data")
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    //Local notif
    func scheduleLocal(title : String!, description : String!) {
        let content = UNMutableNotificationContent()

        content.categoryIdentifier = "pinBildirimi"
        content.title = title!
        content.body = description!
        content.sound = UNNotificationSound.default()

        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(identifier: "OneSecond", content: content, trigger: trigger)
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()

        center.add(request) { (error) in
            print(error as Any)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.startMonitoringSignificantLocationChanges()
    }

    
    func setupLocationManager(){
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.startUpdatingLocation()
    }
    
//    func createRegion(location:CLLocation?) {
//
//        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
//            let coordinate = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
//            let regionRadius = 10.0
//
//            let region = CLCircularRegion(center: CLLocationCoordinate2D(
//                latitude: coordinate.latitude,
//                longitude: coordinate.longitude),
//                                          radius: regionRadius,
//                                          identifier: "aabb")
//
//            region.notifyOnExit = true
//            region.notifyOnEntry = true
//
//            //Send your fetched location to server
//
//            //Stop your location manager for updating location and start regionMonitoring
//            self.locationManager.stopUpdatingLocation()
//            self.locationManager.startMonitoring(for: region)
//        }
//        else {
//            print("System can't track regions")
//        }
//    }
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if UIApplication.shared.applicationState == .active {
            currentLocation = locations.last!
            let location = locations.last
            lastLocation = location!
            
        } else {
            
            let location = locations.last
            lastLocation = location!
            currentLocation = location!
            print("not active with location: \(location?.coordinate)")
            self.scheduleLocal(title: "Location Update", description: "Pos: \(location!.coordinate)")
        }
    }
    
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}

