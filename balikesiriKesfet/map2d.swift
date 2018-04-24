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
    var id : Int!
    var title : String!
    var info : String!
    var lat : String!
    var lng : String!
    var pic : String!
    var distance : Double!
    var type : Int!
    var gallery : [String] = []
}

class map2d: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, SWRevealViewControllerDelegate {
    var updateView = false
    var locatFirstUpdated = false
    var pinList = [Pin]()
    var selectedPinId : Int!
    var passedPinId : Int!
    var deSelectedPinID : Int!
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var annotationList : [MKPointAnnotation] = []
    var sv : UIView!
    var model : String!
    
    let prefs:UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var annotationPopupExitBut: UIButton!
    @IBOutlet weak var popupScrollView: UIScrollView!
    @IBOutlet weak var pinListTV: UITableView!
    @IBOutlet weak var pinInfo: UILabel!
    @IBOutlet weak var pinTitle: UILabel!
    @IBOutlet var annotationPopup: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    @IBOutlet weak var pinGalleryColView: UICollectionView!
    @IBOutlet weak var mapFollowButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pinListView: UIView!
    @IBOutlet weak var lockButtonBG: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinList.removeAll()
        //Get the device model
        model = UserDefaults.standard.string(forKey: "currentDeviceModel")
        print(model!)
        
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 240
        revealViewController().rearViewRevealOverdraw = 300
        revealViewController().delegate = self
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.selectedPinId = -1
        self.deSelectedPinID = -1
        self.passedPinId = self.prefs.integer(forKey: "mapSelectedPinId")
        NSLog("passed: \(self.passedPinId)")
        self.addressLabel.text = ""
        self.mapFollowButton.setImage(#imageLiteral(resourceName: "locat"), for: .normal)

        annotationPopup.layer.cornerRadius = 5
        annotationPopup.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopup.layer.borderWidth = 1
        switch model {
        case "iPhone 5c","iPhone 5","iPhone 5s","iPhone SE":
            print("\n\nmodel worked")
            print(model)
            self.annotationPopup.frame.size.width = self.annotationPopup.frame.size.width * 0.8516
            self.annotationPopup.frame.size.height = self.annotationPopup.frame.size.height * 0.8516
            break
        default:
            break
        }
        
        self.mapKitView.delegate = self
        self.mapKitView.showsUserLocation = true
        //mapKitView.layer.cornerRadius = 5
        
        popupScrollView.layer.cornerRadius = 5
        popupScrollView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopupExitBut.layer.cornerRadius = 5
        annotationPopupExitBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        annotationPopupExitBut.layer.borderWidth = 1
        
        pinGalleryColView.layer.cornerRadius = 5
        pinGalleryColView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        pinGalleryColView.layer.borderWidth = 1
        
        //
        self.pinListTV.delegate = self
        self.pinListTV.estimatedRowHeight = 80.0
        self.pinListTV.rowHeight = UITableViewAutomaticDimension
        
        //Ask authorisation
        self.locationManager.requestAlwaysAuthorization()
        //Foreground use
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled(){
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }
        
        //Set lock button bg
        //self.lockButtonBG.layer.cornerRadius = 5
        let path = UIBezierPath(roundedRect:self.lockButtonBG.bounds,
                                byRoundingCorners:[.topLeft, .bottomLeft],
                                cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        lockButtonBG.layer.mask = maskLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.passedPinId = -1
    }
    
    func animateIn() {
        self.view.addSubview(annotationPopup)
        annotationPopup.center = self.view.center
        
        annotationPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        annotationPopup.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.annotationPopup.alpha = 1
            self.annotationPopup.transform = CGAffineTransform.identity
        })
    }
    
    func animateOut() {
        self.pinInfo.text = "";
        UIView.animate(withDuration: 0.3, animations: {
            self.annotationPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.annotationPopup.alpha = 0
            
        }, completion: {
            (success:Bool) in
                self.annotationPopup.removeFromSuperview()
        })
    }
    
    @IBAction func updateViewToggle(_ sender: Any) {
        updateView = !updateView
        if(!updateView){
            mapFollowButton.setImage(#imageLiteral(resourceName: "locat"), for: .normal)
        } else {
            mapFollowButton.setImage(#imageLiteral(resourceName: "locatFollow"), for: .normal)
        }
    }

    //Click pin from 2d map
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for pin in self.pinList {
            if pin.title == (view.annotation?.title)! {
                self.selectedPinId = pin.id
                self.pinTitle.text = pin.title
                self.pinInfo.text = pin.info
                if(self.pinList[self.selectedPinId].gallery.count > 0) {
                    self.pinGalleryColView.isHidden = false
                    DispatchQueue.main.async {
                        self.pinGalleryColView.reloadData()
                    }
                } else {
                    self.pinGalleryColView.isHidden = true
                }
                let indPath = NSIndexPath(item: self.selectedPinId, section: 0)
                self.pinListTV.selectRow(at: indPath as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                //self.pinListTV.scrollToRow(at: indPath as IndexPath, at: .middle, animated: true)
                break
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.selectedPinId = -1
        self.pinListTV.deselectRow(at: self.pinListTV.indexPathForSelectedRow!, animated: true)
    }
    
    
    //Update userLocation on map view
    func mapView(_ mapView: MKMapView,
                 didUpdate userLocation: MKUserLocation) {
        //Get user's region and adress
        self.geocode(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude) { placemark, error in
            guard let placemark = placemark, error == nil else { return }
            // you should always update your UI in the main thread
            DispatchQueue.main.async {
                //  update UI here
//                print("address1:", placemark.thoroughfare ?? "")
//                print("address2:", placemark.subThoroughfare ?? "")
//                print("city:",     placemark.locality ?? "")
//                print("state:",    placemark.administrativeArea ?? "")
//                print("zip code:", placemark.postalCode ?? "")
//                print("country:",  placemark.country ?? "")
                self.addressLabel.text = "\(placemark.thoroughfare!) \(placemark.locality!) \(placemark.administrativeArea!)"
            }
        }
    }
    
    //reverse geocoder
    func geocode(latitude: Double, longitude: Double, completion: @escaping (CLPlacemark?, Error?) -> ())  {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude)) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                completion(nil, error)
                return
            }
            completion(placemark, nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
    }
    
    @IBAction func dismissAnnPopup(_ sender: Any) {
        animateOut()
    }
    
    func getPinInfoFromWebMap() {
        self.sv = UIViewController.displaySpinner(onView: self.pinListView)
        
        //http://app.balikesirikesfet.com/json_distance?lat=%@&lng=%@&dis=1
        //http://app.balikesirikesfet.com/json?l=1000
        
        let urlString = "http://app.balikesirikesfet.com/json_distance?lat=\(self.currentLocation.coordinate.latitude)&lng=\(self.currentLocation.coordinate.longitude)&dis=2"
        print(urlString)
        let urlRequest = URLRequest(url: URL(string: urlString)!)
        
        //temp request test
        if let myURL = NSURL(string: urlString) {
            do {
                let myHTMLString = try NSString(contentsOf: myURL as URL, encoding: String.Encoding.utf8.rawValue)
                NSLog("url content: \(myHTMLString)")
            } catch {
                print(error)
            }
        }

        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            self.pinList.removeAll(keepingCapacity: false)
            self.pinList = []
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]
                if json.count <= 0 {
                    let alert = UIAlertController(title: "UYARI", message: "Bulunduğunuz noktanın yakınlarında herhangi bir yer bildirimi bulunmamaktadır!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {
                        action in
                        switch action.style{
                        case .default:
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "anaSayfaVC")
                            self.navigationController?.pushViewController(controller, animated: true)
                            break
                        case.cancel:
                            break
                        case.destructive:
                            break
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
                var tmpPin = Pin()
                var count : Int
                count = 0
                for pin in json {
                    let selectedType = UserDefaults.standard.integer(forKey: "pinCategorySelection") as Int
                    
                    if let title = pin["title"] as? String{
                        tmpPin.title = title
                    }
                    
                    if let type = pin["type"] as? String{
                        tmpPin.type = Int(type)
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
                    tmpPin.info = " "
                    if let info = pin["description"] as? String {
                        print("info: " + info)
                        if(info.isEmpty) {
                            tmpPin.info = " "
                        } else {
                        tmpPin.info = info
                        }
                    }
                    if let date1 = pin["date1"] as? String {
                        print(date1)
                        if(date1.isEmpty == false && selectedType == tmpPin.type && selectedType == 1) {
                            tmpPin.info = tmpPin.info + "\nEtkinlik Başlangıcı: " + date1
                        } else {
                            
                        }
                    }
                    if let time1 = pin["time1"] as? String {
                        if(time1.isEmpty == false && selectedType == tmpPin.type && selectedType == 1) {
                            tmpPin.info = tmpPin.info + " - " + time1 + "\n"
                        } else {
                            
                        }
                    }
                    if let date2 = pin["date2"] as? String {
                        if(date2.isEmpty == false && selectedType == tmpPin.type && selectedType == 1) {
                            tmpPin.info = tmpPin.info + "Etkinlik Sonu: " + date2
                        } else {
                            
                        }
                    }
                    if let time2 = pin["time2"] as? String {
                        if(time2.isEmpty  == false && selectedType == tmpPin.type && selectedType == 1) {
                            tmpPin.info = tmpPin.info + " - " + time2
                        } else {
                            
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
                    
                    if(selectedType != tmpPin.type && selectedType != -1){
                        print("Skipped ",tmpPin.title,tmpPin.type)
                        continue
                    }
                    print("Not skipped ",tmpPin.title,tmpPin.type)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: (tmpPin.lat! as NSString).doubleValue, longitude: (tmpPin.lng! as NSString).doubleValue)
                    annotation.title = tmpPin.title;
                    
                    var distance : Double
                    distance = self.currentLocation.distance(from: CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)) / 1000.0
                    tmpPin.distance = distance
                    
                    self.mapKitView.addAnnotation(annotation)
                    self.annotationList.append(annotation)
                    
                    tmpPin.id = count
                    count = count + 1
                    
                    self.pinList.append(tmpPin)
                    tmpPin = Pin()
                }
                
                if self.pinList.count <= 0 {
                    let alert = UIAlertController(title: "UYARI", message: "Bulunduğunuz noktanın yakınlarında herhangi bir yer bildirimi bulunmamaktadır!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {
                        action in
                        switch action.style{
                        case .default:
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "anaSayfaVC")
                            self.navigationController?.pushViewController(controller, animated: true)
                            break
                        case.cancel:
                            break
                        case.destructive:
                            break
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                
                self.pinList.sort{$0.distance! < $1.distance!}
                DispatchQueue.main.async {
                    self.pinListTV.reloadData() {
                        UIViewController.removeSpinner(spinner: self.sv)
                    }
                    if self.passedPinId > -1 {
                        self.selectedPinId = self.passedPinId
                        self.prefs.set(-1, forKey: "mapSelectedPinId")
                        self.mapKitView.selectAnnotation(self.annotationList[self.passedPinId], animated: true)
                        let indPath = NSIndexPath(item: self.passedPinId, section: 0)
                        
                        var region : MKCoordinateRegion!
                        var span : MKCoordinateSpan!
                        span = MKCoordinateSpanMake(0.0025, 0.0025)
                        region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(Double(self.pinList[self.selectedPinId].lat!)!, Double(self.pinList[self.selectedPinId].lng!)!), span: span)
                        self.mapKitView.setRegion(region, animated: true)
                        self.pinListTV.selectRow(at: indPath as IndexPath, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    }
                }
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
        self.currentLocation = locations.last!;
        let location = locations.last! as CLLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        if updateView == true {
            self.mapKitView.setRegion(region, animated: true)
        }
        
        if self.locatFirstUpdated == false {
            self.locatFirstUpdated = true
            self.mapKitView.setRegion(region, animated: true)
            self.getPinInfoFromWebMap()
        }
    }
    
    //Pinlist table view
    func openInfoButClicked(_ sender: UIButton) {
        selectedPinId = sender.tag
        pinTitle.text = pinList[sender.tag].title
        pinInfo.text = " "
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
        cell.cardView.backgroundColor = UIColor(red: 49/255, green: 100/255, blue: 147/255, alpha: 1.0)
        if(indexPath.row == self.selectedPinId) {
            cell.cardView.backgroundColor = UIColor(red: 59/255, green: 110/255, blue: 177/255, alpha: 1.0)
        }
        cell.contentView.backgroundColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0)
        var distance : Double
        var pinLocation : CLLocation
        pinLocation = CLLocation(latitude: Double(self.pinList[indexPath.item].lat!)!, longitude: Double(self.pinList[indexPath.item].lng!)!)
        distance = currentLocation.distance(from: pinLocation) / 1000.0
        cell.pinTitleLabel.text = String(format: "%@ - %@",self.pinList[indexPath.item].title,String(format: "%.1f KM",distance))
        //cell.distanceLabel.text = String(format: "%.1f KM", distance)
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
        NSLog("selected... %d", indexPath.row)
        self.selectedPinId = indexPath.row
        if(updateView) {
            updateView = false
            mapFollowButton.setImage(#imageLiteral(resourceName: "locat"), for: .normal)
        }
        var region : MKCoordinateRegion!
        var span : MKCoordinateSpan!
        span = MKCoordinateSpanMake(0.0025, 0.0025)
        region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(Double(self.pinList[indexPath.row].lat!)!, Double(self.pinList[indexPath.row].lng!)!), span: span)
        self.mapKitView.setRegion(region, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        NSLog("DEselected... %d", indexPath.row)
        self.deSelectedPinID = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.1, animations: {
            cell.alpha = 1
        })
    }
    

    //Collection view for popup gallery
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pinPicCell", for: indexPath) as! pinPicCell
        cell.detailPic.downloadImage(from: self.pinList[selectedPinId].gallery[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pinList[selectedPinId].gallery.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //SWReveal Delegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        let tagId = 42078
        if(position == FrontViewPosition.left) {
            let lock = self.view.viewWithTag(tagId)
            UIView.animate(withDuration: 0.25, animations: {
                lock?.alpha = 0.0
            }, completion: {(finished: Bool) in
                lock?.removeFromSuperview()
            }
            )
            lock?.removeFromSuperview()
        }
        if(position == FrontViewPosition.right) {
            
            let lock = UIView(frame: self.view.bounds)
            lock.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            lock.tag = tagId
            lock.alpha = 0
            lock.backgroundColor = UIColor.black
            lock.addGestureRecognizer(UITapGestureRecognizer(target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:))))
            self.view.addSubview(lock)
            UIView.animate(withDuration: 0.5, animations: {
                lock.alpha = 0.333
            }
            )
        }
    }
}
