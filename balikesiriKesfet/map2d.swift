//
//  map2d.swift
//  balikesiriKesfet
//
//  Created by xloop on 10/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

struct Pin {
    var title : String?
    var lat : String?
    var lng : String?
}

class map2d: UIViewController, CLLocationManagerDelegate{
    var updateView = false
    
    var pinList = [Pin]()
    
    let locationManager = CLLocationManager()
    
    
    @IBOutlet weak var mapKitView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKitView.showsUserLocation = true
        
        //Ask authorisation
        self.locationManager.requestAlwaysAuthorization()
        //Foreground use
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            getPinInfoFromWebMap()
        }
        getPinInfoFromWebMap()
        
    }
    @IBAction func updateViewToggle(_ sender: Any) {
        updateView = !updateView
    }
    
    func getPinInfoFromWebMap(){
        let urlRequest = URLRequest(url: URL(string: "http://app.balikesirikesfet.com/json?l=1000")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.pinList = []
            
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]
                var tmpPin = Pin()
                for pin in json {
                    if let title = pin["title"] as? String, let lat = pin["lat"] as? String, let lng = pin["lng"] as? String {
                        
                        tmpPin.title = title
                        tmpPin.lat = lat
                        tmpPin.lng = lng
                        
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = CLLocationCoordinate2D(latitude: (lat as NSString).doubleValue, longitude: (lng as NSString).doubleValue)
                        annotation.title = title
                        
                        self.mapKitView.addAnnotation(annotation)
                    }
                    self.pinList.append(tmpPin)
                }
            } catch let error {
                print(error)
            }
        }
        task.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("dsadsadsadsdasdasLocloc loc")
        //let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        if updateView == true {
            self.mapKitView.setRegion(region, animated: true)
        }
    }
}
