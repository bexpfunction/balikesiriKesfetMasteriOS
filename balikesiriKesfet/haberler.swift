//
//  haberler.swift
//  balikesiriKesfet
//
//  Created by xloop on 31/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

struct ArticleN {
    var id : String?
    var title : String?
    var abstract : String?
    var date : String?
    var picUrl : String?

}

class haberler: UIViewController, UITableViewDelegate, UITableViewDataSource, SWRevealViewControllerDelegate{
    
    //Buttons
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    
    @IBOutlet weak var tblView: UITableView!
    
    var articleList : [ArticleN] = []
    
    var sv : UIView!
    
    let network: NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblView.estimatedRowHeight = 156.0
        tblView.rowHeight = UITableViewAutomaticDimension
        
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 250
        revealViewController().delegate = self
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.articleList.removeAll()
        fetchNews()
    }
    
    //Connect and serialize json with json object
    
    func fetchNews(){
        self.sv = UIViewController.displaySpinner(onView: self.view)
        let urlRequest = URLRequest(url: URL(string: "http://app.balikesirikesfet.com/json_news?l=0,100")!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            NSLog("request data: %@", String(data: data!, encoding: .ascii)!)

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
                    self.tblView.reloadData() {
                        UIViewController.removeSpinner(spinner: self.sv)
                    }
                    
                }
            } catch let error {
                print(error as Any)
            }
        }
        
        task.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.articleList.count != 0){
            return (self.articleList.count)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            cell.alpha = 1
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! articleCell
        cell.cardView.layer.cornerRadius = 5
        cell.cardView.layer.borderWidth = 1
        cell.cardView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        cell.cardView.layer.masksToBounds = false
        cell.cardView.layer.shadowColor = UIColor.black.cgColor
        cell.cardView.layer.shadowOffset = CGSize(width: 0.2, height: 0.2)
        cell.cardView.layer.shadowRadius = 0.2
        cell.contentView.backgroundColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0)
        cell.title.text = self.articleList[indexPath.item].title
        cell.abstract.text = self.articleList[indexPath.item].abstract
        cell.date.text = self.articleList[indexPath.item].date
        cell.imgView.downloadImage(from: (self.articleList[indexPath.item].picUrl!))
        cell.imgView.layer.cornerRadius = 3
        cell.imgView.layer.masksToBounds = false
        //cell.contentView.backgroundColor = UIColor(red: 10/255, green: 109/255, blue: 165/255, alpha: 1.0)
        cell.cardView.backgroundColor = UIColor(red: 49/255, green: 100/255, blue: 147/255, alpha: 1.0)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(checkConnection(failMessage: "Haber detayları sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
            let haberDetayVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "haberDetay") as! haberDetaylari
            
            
            haberDetayVC.idFromSelection = self.articleList[indexPath.item].id

            self.navigationController?.pushViewController(haberDetayVC, animated: true)
            //self.present(haberDetayVC, animated: true, completion: nil)
        }
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
    
    func checkConnection(failMessage: String) -> Bool {
        var connected:Bool
        connected = false
        let alert = UIAlertController(title: "UYARI", message: failMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {
            action in
            switch action.style{
            case .default:
                break
            case.cancel:
                break
            case.destructive:
                break
            }
        }))
        
        NetworkManager.isReachable { _ in
            connected = true
        }
        
        NetworkManager.isUnreachable { _ in
            self.present(alert, animated: true, completion: nil)
            connected = false
        }
        
        return connected
    }
}
