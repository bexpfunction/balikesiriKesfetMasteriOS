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
    var pic : String?
    var gallery : [String]? = []
}

class map2d: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    var updateView = false
    
    var pinList = [Pin]()
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation();
    
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
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            getPinInfoFromWebMap()
        }
    }
    @IBAction func updateViewToggle(_ sender: Any) {
        updateView = !updateView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       
    }
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation){
        NSLog("mapview update...")
    }
    
    func getPinInfoFromWebMap() {
        //http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=1
//        let baseString = "http://app.balikesirikesfet.com/json_distance?lat=";
//        let latStr = String(format:"%.8f",currentLocation.coordinate.latitude);
//        let lngStr = String(format:"%.8f",currentLocation.coordinate.longitude);
//        let lastStr = "&dis=200";
//        
//        let generatedString = "\(baseString)\(latStr)&lng=\(lngStr)\(lastStr)"
//        NSLog("%@", generatedString);
        
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
                    if let title = pin["title"] as? String{
                        tmpPin.title = title
                    }
                    if let lat = pin["lat"] as? String{
                        tmpPin.lat = lat
                    }
                    if let lng = pin["lng"] as? String{
                        tmpPin.lng = lng
                    }
                    if let pic = pin["pic"] as? String {
                        tmpPin.pic = pic

                    }
                    if let gallery = pin["pic2"] as? [String] {
                        for pct in gallery {
                            let pictUrl = "http://app.balikesirikesfet.com/"+pct
                            tmpPin.gallery?.append(pictUrl)
                        }
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (tmpPin.lat! as NSString).doubleValue, longitude: (tmpPin.lng! as NSString).doubleValue)
                    annotation.title = tmpPin.title;
                    self.mapKitView.addAnnotation(annotation)
                    
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

        currentLocation = locations.last!;
        let location = locations.last! as CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        if updateView == true {
            self.mapKitView.setRegion(region, animated: true)
        }
    }
}
