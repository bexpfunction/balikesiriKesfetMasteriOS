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
    var title : String!
    var info : String!
    var lat : String!
    var lng : String!
    var pic : String!
    var distance : Double!
    var gallery : [String] = []
}

class map2d: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    var updateView = false
    
    var pinList = [Pin]()
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation();
    
    @IBOutlet weak var annotationPopupExitBut: UIButton!
    @IBOutlet weak var popupScrollView: UIScrollView!
    @IBOutlet weak var pinListTV: UITableView!
    @IBOutlet weak var pinInfo: UILabel!
    @IBOutlet weak var pinTitle: UILabel!
    @IBOutlet var annotationPopup: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var pinGalleryColView: UICollectionView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var effect:UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visualEffectView.alpha = 0.75
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        visualEffectView.isHidden = true
        annotationPopup.layer.cornerRadius = 5
        annotationPopup.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopup.layer.borderWidth = 1
        
        mapKitView.showsUserLocation = true
        mapKitView.layer.cornerRadius = 5
        
        popupScrollView.layer.cornerRadius = 5
        popupScrollView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopupExitBut.layer.cornerRadius = 5
        annotationPopupExitBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopupExitBut.layer.borderWidth = 1
        
        pinGalleryColView.layer.cornerRadius = 5
        pinGalleryColView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        pinGalleryColView.layer.borderWidth = 1
        
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
    
    func animateIn() {
        self.visualEffectView.isHidden = false
        self.view.addSubview(annotationPopup)
        annotationPopup.center = self.view.center
        
        annotationPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        annotationPopup.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.visualEffectView.effect = self.effect
            self.annotationPopup.alpha = 1
            self.annotationPopup.transform = CGAffineTransform.identity
        })
    }
    
    func animateOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.annotationPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.annotationPopup.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }, completion: {
            (success:Bool) in
                self.annotationPopup.removeFromSuperview()
                self.visualEffectView.isHidden = true
        })
    }
    
    @IBAction func updateViewToggle(_ sender: Any) {
        updateView = !updateView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        pinTitle.text = view.annotation?.title.unsafelyUnwrapped
        animateIn()
    }
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation){

    }
    
    @IBAction func dismissAnnPopup(_ sender: Any) {
        animateOut()
    }
    
    func getPinInfoFromWebMap() {
        //http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=1
      
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
                    if let info = pin["description"] as? String {
                        if(info.isEmpty) {
                            tmpPin.info = ""
                        } else {
                        tmpPin.info = info
                        }
                    }
                    
                    if let gallery = pin["pic2"] as? [String] {
                        tmpPin.gallery.removeAll(keepingCapacity: false)
                        for pct in gallery {
                            if(!pct.isEmpty){
                                let pictUrl = "http://app.balikesirikesfet.com/"+pct
                                tmpPin.gallery.append(pictUrl)
                            }
                        }
                    }
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (tmpPin.lat! as NSString).doubleValue, longitude: (tmpPin.lng! as NSString).doubleValue)
                    annotation.title = tmpPin.title;
                    
                    var distance : Double
                    distance = self.currentLocation.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) / 1000.0
                    tmpPin.distance = distance
                    
                    self.mapKitView.addAnnotation(annotation)
                    
                    self.pinList.append(tmpPin)
                }
                self.pinList.sort{$0.distance! < $1.distance!}
                DispatchQueue.main.async {
                    self.pinListTV.reloadData()
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
    var selectedPinId : Int!
    //Pinlist table view
    func openInfoButClicked(_ sender: UIButton) {
        selectedPinId = sender.tag
        pinTitle.text = pinList[sender.tag].title
        pinInfo.text = pinList[sender.tag].info
        if(pinList[sender.tag].gallery.count > 0) {
            pinGalleryColView.isHidden = false
            DispatchQueue.main.async {
                self.pinGalleryColView.reloadData()
            }
        } else {
            pinGalleryColView.isHidden = true
        }
        animateIn()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pinListCell", for: indexPath) as! pinListCell
        cell.cardView.layer.cornerRadius = 5
        cell.cardView.layer.borderWidth = 1
        cell.cardView.layer.borderColor = UIColor.white.cgColor
        cell.cardView.layer.masksToBounds = true
        cell.cardView.layer.shadowColor = UIColor.black.cgColor
        cell.cardView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        cell.cardView.layer.shadowRadius = 0.2
        cell.contentView.backgroundColor = UIColor(red: 49/255, green: 100/255, blue: 147/255, alpha: 1.0)
        cell.pinTitleLabel.text = self.pinList[indexPath.item].title
        var distance : Double
        var pinLocation : CLLocation
        
        pinLocation = CLLocation(latitude: Double(self.pinList[indexPath.item].lat!)!, longitude: Double(self.pinList[indexPath.item].lng!)!)
        distance = currentLocation.distance(from: pinLocation) / 1000.0
        cell.distanceLabel.text = String(format: "%.1f KM", distance)
        cell.cardView.backgroundColor = UIColor(red: 49/255, green: 100/255, blue: 147/255, alpha: 1.0)
        cell.openInfoBut.tag = indexPath.row
        cell.openInfoBut.addTarget(self, action: #selector(self.openInfoButClicked(_:)), for: UIControlEvents.touchUpInside)
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.pinList.count>0) {
            return (self.pinList.count)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var region : MKCoordinateRegion!
        var span : MKCoordinateSpan!
        span = MKCoordinateSpanMake(0.00025, 0.00025)
        region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(Double(self.pinList[indexPath.item].lat!)!, Double(self.pinList[indexPath.item].lng!)!), span: span)
        mapKitView.setRegion(region, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 1
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinPicCell", for: indexPath) as! pinPicCell
        cell.detailPic.downloadImage(from: self.pinList[selectedPinId].gallery[indexPath.item])
        print("downloading image: \(self.pinList[selectedPinId].gallery[indexPath.item])")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pinList[selectedPinId].gallery.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}
