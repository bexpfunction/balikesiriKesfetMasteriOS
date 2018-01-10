//
//  duyurular.swift
//  balikesiriKesfet
//
//  Created by xloop on 26/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

struct NotificationN {
    var id : String?
    var title : String?
    var abstract : String?
    var date : String?
}

class duyurular: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Reveal controller bar button
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    
    @IBOutlet weak var notificationsTable: UITableView!
    
    var sv : UIView!
    var notificationList : [NotificationN] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 200
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        
        notificationList.removeAll()
        fetchNotifications()
        // Do any additional setup after loading the view.
    }

    func fetchNotifications(){
        self.sv = UIViewController.displaySpinner(onView: self.view)
        let notUrlRequest = URLRequest(url: URL(string: "http://app.balikesirikesfet.com/json_notifications?l=0,3")!)
        
        let notifTask = URLSession.shared.dataTask(with: notUrlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]
                var tmpNotif = NotificationN()
                for notifInJson in json{
                    if let title = notifInJson["title"] as? String, let id = notifInJson["id"] as? String, let abstract = notifInJson["abstract"] as? String, let date = notifInJson["date"] as? String {
                        tmpNotif.id = id
                        tmpNotif.title = title
                        tmpNotif.abstract = abstract
                        tmpNotif.date = date
                    }
                    self.notificationList.append(tmpNotif)
                }
                DispatchQueue.main.async {
                    self.notificationsTable.reloadData() {
                        UIViewController.removeSpinner(spinner: self.sv)
                    }
                }
            } catch let error {
                print(error as Any)
            }
        }
        
        notifTask.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.notificationList.count != 0){
            return (self.notificationList.count)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! notificationCell
        cell.cardView.layer.cornerRadius = 5
        cell.cardView.layer.borderWidth = 1
        cell.cardView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.cardView.layer.masksToBounds = false
        cell.cardView.layer.shadowColor = UIColor.black.cgColor
        cell.cardView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        cell.cardView.layer.shadowRadius = 0.2
        cell.cardView.backgroundColor = UIColor(red: 49/255, green: 100/255, blue: 147/255, alpha: 1.0)
        cell.contentView.backgroundColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0)
        cell.nTitle.text = self.notificationList[indexPath.item].title
        cell.nAbstract.text = self.notificationList[indexPath.item].abstract
        cell.nDate.text = self.notificationList[indexPath.item].date
            
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
