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
        UserDefaults.standard.set(UIDevice.current.modelName, forKey: "currentDeviceModel")
        
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
            let map2dVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "haritaNavC") as! map2d
            let navigationController = self.window?.rootViewController as! UINavigationController
            navigationController.pushViewController(map2dVC, animated: true)
            //handle tapping on push notification and here you can open needed controller
            
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

    
    func fetchPinsWith(lat: Double, lng: Double) {
        let urlString = "http://app.balikesirikesfet.com/json_distance?lat=\(NSString(format: "%.10f",lat))&lng=\(NSString(format: "%.10f",lng))&dis=2"
        print("url: \(urlString)")
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]
                var notifiedPins = UserDefaults.standard.array(forKey: "notifiedPinList") as? [String]
                for pin in json {
                    if (pin["bildirim"] as? String) != nil {
                        if(notifiedPins == nil) {
                            notifiedPins = []
                            let pinId = pin["id"] as? String
                            notifiedPins?.append(pinId!)
                            UserDefaults.standard.set(notifiedPins, forKey: "notifiedPinList")
                            let title = pin["title"] as! String
                            DispatchQueue.main.async {
                                if UIApplication.shared.applicationState != .active {
                                    self.scheduleLocal(title: "Yeni Yer Bildirimi", description: "\(title) çok yakınınızda")
                                }
                            }
                            break
                        } else {
                            let pinId = pin["id"] as! String
                            if(notifiedPins?.contains(pinId))!{
                                
                            } else {
                                notifiedPins?.append(pinId)
                                UserDefaults.standard.set(notifiedPins, forKey: "notifiedPinList")
                                let title = pin["title"] as! String
                                if UIApplication.shared.applicationState != .active {
                                    self.scheduleLocal(title: "Yeni Yer Bildirimi", description: "\(title) çok yakınınızda")
                                }
                                break
                            }
                        }
                    }
                }
                
                notifiedPins?.removeAll()
            } catch let error {
                print(error)
            }
        }
        task.resume()
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
    
    
    // Below method will provide you current location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if UIApplication.shared.applicationState == .active {
            currentLocation = locations.last!
            let location = locations.last
            lastLocation = location!
        } else {
            self.fetchPinsWith(lat: (locations.last?.coordinate.latitude)!, lng: (locations.last?.coordinate.longitude)!)
            let location = locations.last
            lastLocation = location!
            currentLocation = location!
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        createRegion(location: self.currentLocation)
//        self.scheduleLocal(title: "Yeni Yer Bildirimi", description: "\(self.currentLocation.coordinate) çok yakınınızda")
//    }
    
    
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
//            print("Region created with: \(location?.coordinate)")
//        }
//        else {
//            print("System can't track regions")
//        }
//    }
    
    // Below Mehtod will print error if not able to update location.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }
}

