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

    @IBOutlet weak var notificationsTable: UITableView!
    var notificationList : [NotificationN] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationList.removeAll()
        fetchNotifications()
        // Do any additional setup after loading the view.
    }

    func fetchNotifications(){
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
                    self.notificationsTable.reloadData()
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
            cell.nTitle.text = self.notificationList[indexPath.item].title
            cell.nAbstract.text = self.notificationList[indexPath.item].abstract
            cell.nDate.text = self.notificationList[indexPath.item].date
            if(indexPath.row % 2 == 0){
                cell.contentView.backgroundColor = UIColor(red: 20/255, green: 119/255, blue: 175/255, alpha: 1.0)
            }
            else {
                cell.contentView.backgroundColor = UIColor(red: 150/255, green: 194/255, blue: 34/255, alpha: 1.0)
            }
            
            return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
