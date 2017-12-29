//
//  ViewController.swift
//  balikesiriKesfet
//
//  Created by xloop on 30/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, FBSDKLoginButtonDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var newsTable: UITableView!

    @IBOutlet weak var notificationTable: UITableView!
    @IBOutlet weak var fbProfileImage: UIImageView!
    //Menu constraints for animation
    @IBOutlet weak var menuConstraint: NSLayoutConstraint!
    
    //Menu view on homePage
    @IBOutlet weak var menuView: UIView!
    
    //Menu button on homePage
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //Menu is on or off bool
    var menuOn = false
    
    @IBOutlet weak var fbLogInButton: FBSDKLoginButton!
    
    var articleList : [ArticleN] = []
    var notificationList : [NotificationN] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.articleList.removeAll()
        
        fbLogInButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLogInButton.delegate = self
        

        //Set menu attributes
        menuView.layer.shadowOpacity = 0;
        menuView.layer.shadowRadius = 0;
        
        let menuButtonImage = UIImage(named: "220px-Hamburger_icon.png")
        
        //Set menu button attributes
        menuButton.image = menuButtonImage
        
        fbProfileImage.layer.masksToBounds = true
        fbProfileImage.layer.cornerRadius = 40
        
        if((FBSDKAccessToken.current()) != nil){
            fbProfileImage.isHidden = false
            let profImg = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID!+"/picture?type=large"
            fbProfileImage.downloadImage(from: profImg)
        } else {
            fbProfileImage.isHidden = true
        }
        
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.articleList.removeAll()
        self.notificationList.removeAll()
        fetchNews()
        fetchNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        if(menuOn){
            menuConstraint.constant = -170;
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
            menuOn = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fbProfileImage.layer.masksToBounds = true
        fbProfileImage.layer.cornerRadius = 40
        
        if((FBSDKAccessToken.current()) != nil){
            fbProfileImage.isHidden = false
            let profImg = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID!+"/picture?type=large"
            fbProfileImage.downloadImage(from: profImg)
        } else {
            fbProfileImage.isHidden = true
        }
    }
    
    @IBAction func openMenu(_ sender: Any) {
        
        if(menuOn){
            menuConstraint.constant = -170;
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        } else {
            menuConstraint.constant = 0;
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()})
        }
        menuOn = !menuOn;
    }

    
    
    //MARK: FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            fbProfileImage.isHidden = true
            // Process error
            //print ("facebook login error")
            
            performSegue(withIdentifier: "toLogin", sender: self)
        }
        else if result.isCancelled {
            fbProfileImage.isHidden = true
            // Handle cancellations
            //print ("facebook login cancelled")
            performSegue(withIdentifier: "toLogin", sender: self)
        }
        else {
            fbProfileImage.isHidden = false
            let profImg = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID!+"/picture?type=large"
            fbProfileImage.downloadImage(from: profImg)
            // Navigate to other view
            //print ("facebook login complete")
        }
    }
    
    
    func fetchNews(){
        let urlRequest = URLRequest(url: URL(string: "http://app.balikesirikesfet.com/json_news?l=0,3")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [[String:AnyObject]]
                var tmpArticle = ArticleN()
                for articleInJson in json{
                    if let title = articleInJson["title"] as? String, let id = articleInJson["id"] as? String, let abstract = articleInJson["abstract"] as? String, let picUrl = articleInJson["pic"] as? String, let date = articleInJson["date"] as? String {
                        tmpArticle.id = id
                        tmpArticle.title = title
                        tmpArticle.abstract = abstract
                        let picUrlBegin = "http://app.balikesirikesfet.com/file/"
                        tmpArticle.picUrl = picUrlBegin + picUrl
                        tmpArticle.date = date
                    }
                    self.articleList.append(tmpArticle)
                }
                DispatchQueue.main.async {
                    self.newsTable.reloadData()
                }
            } catch let error {
                print(error as Any)
            }
        }
        
        task.resume()
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
                    //print(tmpNotif)
                }
                DispatchQueue.main.async {
                    self.notificationTable.reloadData()
                }
            } catch let error {
                print(error as Any)
            }
        }
        
        notifTask.resume()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print ("logged out of facebook")
        performSegue(withIdentifier: "toLogin", sender: view)
    }
    
    @IBAction func quitApp(_ sender: Any) {
        exit(0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == self.newsTable) {
            if(self.articleList.count != 0){
                return (self.articleList.count)
            }
        }
        if(tableView == self.notificationTable) {
            if(self.notificationList.count != 0){
                return (self.notificationList.count)
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == self.newsTable {
            cell.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                cell.alpha = 1
            })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.newsTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! articleCell
            cell.cardView.layer.cornerRadius = 3
            cell.cardView.layer.masksToBounds = false
            cell.cardView.layer.shadowColor = UIColor.black.cgColor
            cell.cardView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
            cell.cardView.layer.shadowRadius = 0.2
            cell.contentView.backgroundColor = UIColor(red: 10/255, green: 109/255, blue: 165/255, alpha: 1.0)
            cell.title.text = self.articleList[indexPath.item].title
            cell.abstract.text = self.articleList[indexPath.item].abstract
            cell.date.text = self.articleList[indexPath.item].date
            cell.imgView.downloadImage(from: (self.articleList[indexPath.item].picUrl!))
            cell.imgView.layer.cornerRadius = 3
            cell.imgView.layer.masksToBounds = false
            if(indexPath.row % 2 == 0){
                //cell.contentView.backgroundColor = UIColor(red: 10/255, green: 109/255, blue: 165/255, alpha: 1.0)
                cell.cardView.backgroundColor = UIColor(red: 20/255, green: 119/255, blue: 175/255, alpha: 1.0)
            }
            else {
                //cell.contentView.backgroundColor = UIColor(red: 140/255, green: 184/255, blue: 24/255, alpha: 1.0)
                cell.cardView.backgroundColor = UIColor(red: 150/255, green: 194/255, blue: 34/255, alpha: 1.0)
            }
            
            return cell
        }
        if tableView == self.notificationTable {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! notificationCell
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.newsTable {
            let haberDetayVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "haberDetay") as! haberDetaylari
            
            
            haberDetayVC.idFromSelection = self.articleList[indexPath.item].id
            
            self.navigationController?.pushViewController(haberDetayVC, animated: true)
            //self.present(haberDetayVC, animated: true, completion: nil)
        }
    }
}

