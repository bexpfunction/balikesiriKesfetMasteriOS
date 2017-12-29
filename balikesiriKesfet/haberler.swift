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

class haberler: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tblView: UITableView!
    
    var articleList : [ArticleN] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.articleList.removeAll()
        fetchNews()
    }
    
    //Connect and serialize json with json object
    
    func fetchNews(){
        let urlRequest = URLRequest(url: URL(string: "http://app.balikesirikesfet.com/json_news?l=0,100")!)

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
                    self.tblView.reloadData()
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
           // cell.contentView.backgroundColor = UIColor(red: 140/255, green: 184/255, blue: 24/255, alpha: 1.0)
            cell.cardView.backgroundColor = UIColor(red: 150/255, green: 194/255, blue: 34/255, alpha: 1.0)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let haberDetayVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "haberDetay") as! haberDetaylari
        
        
        haberDetayVC.idFromSelection = self.articleList[indexPath.item].id

        self.navigationController?.pushViewController(haberDetayVC, animated: true)
        //self.present(haberDetayVC, animated: true, completion: nil)
    }
}

extension UIImageView {
    
    func downloadImage(from url: String){
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data,response,error) in
            
            if error != nil {
                print(error as Any)
                return
            }
            
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        task.resume()
    }
}
