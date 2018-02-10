//
//  haberDetaylari.swift
//  balikesiriKesfet
//
//  Created by xloop on 15/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FBSDKLoginKit

class haberDetaylari: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var thumbsImage: UIImageView!
    @IBOutlet weak var newsAbstract: UILabel!
    @IBOutlet weak var newsText1: UILabel!
    @IBOutlet weak var newsText2: UILabel!
    @IBOutlet weak var linkListText: UITextView!
    @IBOutlet weak var galleryColView: UICollectionView!
    @IBOutlet weak var scrollableContentView: UIView!
    @IBOutlet weak var fbShareButton: FBSDKShareButton!
    
    var idFromSelection : String?
    
    var id : String?
    var titleN : String?
    var ozet : String?
    var anaMetin1 : String?
    var anaMetin2 : String?
    var pic : String?
    var linkList : [String?] = []
    var galeri : [String?] = []
    var sv : UIView!
    var CellWidth : Int?
    var CellCount : Int?
    var CellSpacing : Int?
    
    let network: NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 250
        revealViewController().delegate = self
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        self.newsTitle.text = ""
        self.newsText1.text = ""
        self.newsText2.text = ""
        self.linkListText.text = ""
        self.newsAbstract.text = ""
        self.linkList.removeAll()
        
        self.thumbsImage.layer.borderWidth = 1
        self.thumbsImage.layer.borderColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0).cgColor
        self.thumbsImage.layer.cornerRadius = 1
        
        //Gallery Collection View Setup
        //self.galleryColView.layer.cornerRadius = 5
        //self.galleryColView.layer.borderWidth = 1
        //self.galleryColView.layer.borderColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0).cgColor
        self.galleryColView.flashScrollIndicators()
        
        self.linkListText.delegate = self
        if(FBSDKAccessToken.current() == nil) {
            self.fbShareButton.isHidden = true
        } else {
            self.fbShareButton.isHidden = false
        }
        fetchDetails()
    }
    
    
    func fetchDetails() {
        self.sv = UIViewController.displaySpinner(onView: self.view)
        let detailUrl = "http://app.balikesirikesfet.com/news_detail?h="+idFromSelection!
        
        let urlRequest = URLRequest(url: URL(string: detailUrl)!)
        
        let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
            if error != nil {
                print(error as Any)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                
                if let title = json["title"] as? String {
                    self.titleN = title
                }
                if let abstract = json["ozet"] as? String {
                    self.ozet = abstract
                }
                if let mainText1 = json["ana_metin1"] as? String {
                    self.anaMetin1 = mainText1
                }
                if let mainText2 = json["ana_metin2"] as? String {
                    self.anaMetin2 = mainText2
                }
                if let pict = json["pic"] as? String {
                    self.pic = pict
                }
                if let linkList = json["link"] as? [String] {
                    for link in linkList{
                        let linkUrl = link
                        self.linkList.append(linkUrl+"\n")
                    }
                }
                if let picList = json["galeri"] as? [String] {
                    for pict in picList{
                        let pictUrl = "http://app.balikesirikesfet.com/"+pict
                        self.galeri.append(pictUrl)
                    }
                }
                
                DispatchQueue.main.async {
                    self.newsTitle.text = self.titleN
                    self.newsText1.text = self.anaMetin1
                    self.newsText2.text = self.anaMetin2
                    self.newsAbstract.text = self.ozet
                    let imgRootLink = "http://app.balikesirikesfet.com/file/"
                    self.thumbsImage.downloadImage(from: imgRootLink+self.pic!)
                    self.newsAbstract.sizeToFit()
                    self.newsText1.sizeToFit()
                    self.newsText2.sizeToFit()
                    self.newsTitle.sizeToFit()
                    self.linkListText.text = "";
                    for eLink in self.linkList {
                        self.linkListText.text?.append(eLink!)
                    }
                    self.galleryColView.reloadData()
                    let content : FBSDKShareLinkContent = FBSDKShareLinkContent()
                    content.contentURL = URL(string: "http://app.balikesirikesfet.com/news_detail?h="+self.idFromSelection!)!

                    self.fbShareButton.shareContent = content
                    
                }
                
            } catch let error {
                print(error as Any)
            }
            UIViewController.removeSpinner(spinner: self.sv)
        }
        
        task.resume()
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 354 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 15 * (collectionView.numberOfItems(inSection: 0) - 1)
        
        let leftInset = (collectionView.bounds.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset
        
        return UIEdgeInsetsMake(0, leftInset, 0, rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(checkConnection(failMessage: "Galeri sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
            let galeriVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "galeri") as! galeri
            
            
            galeriVC.imgUrl = self.galeri[indexPath.item]!
            
            self.navigationController?.pushViewController(galeriVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsPicCell", for: indexPath) as! newsPicCell
        cell.detailPic.downloadImage(from: self.galeri[indexPath.item]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.galeri.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
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
    
    //Textview delegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        NSLog("tapped url")
        return true;
    }
    
    //SWReveal Delegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        let tagId = 42078
        if(position == FrontViewPosition.left) {
            let lock = self.view.viewWithTag(tagId)
            lock?.alpha = 0.333
            UIView.animate(withDuration: 0.5, animations: {
                lock?.alpha = 0
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
