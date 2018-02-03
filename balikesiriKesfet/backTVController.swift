//
//  backTVController.swift
//  balikesiriKesfet
//
//  Created by xloop on 09/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class backTVController: UITableViewController, FBSDKLoginButtonDelegate {

    var fbLoggedIn : Bool!
    
    //Facebook image
    @IBOutlet weak var fbProfileImage: UIImageView!
    //Facebook button
    @IBOutlet weak var fbLogOut: FBSDKLoginButton!
    //Cells
    @IBOutlet weak var fbLoginButtonCell: UITableViewCell!
    
    let network: NetworkManager = NetworkManager.sharedInstance
    
    //Button actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Haberler selected
        if(indexPath.row == 1){
            if(checkConnection(failMessage: "Haberler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "haberlerNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        //AG selected
        if(indexPath.row == 2){
            if(checkConnection(failMessage: "Artırılmış gerçeklik moduna ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "agNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        //Harita selected
        if(indexPath.row == 3){
            if(checkConnection(failMessage: "Harita sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "haritaNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        //Duyuru selected
        if(indexPath.row == 4){
            if(checkConnection(failMessage: "Duyurular sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "duyuruNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        
        if(indexPath.row == 6){
            let url = URL(string: "http://www.balikesir.bel.tr")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                //If you want handle the completion block than
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Open url : \(success)")
                })
            }
        }
        if(indexPath.row == 5) {
            if(FBSDKAccessToken.current() == nil) {
                let alert = UIAlertController(title: "UYARI", message: "Mesaj gönderebilmek için mevcut Facebook hesabınız ile giriş yapmanız gerekmektedir.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: { action in
                    switch action.style{
                    case .default:
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: "introVC")
                        self.revealViewController().pushFrontViewController(controller, animated: true)
                        break;
                    case .cancel:
                        break;
                    case .destructive:
                        break;
                    }}))
                self.present(alert, animated: true, completion: nil)
            } else {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "bizeYazNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Facebook Profile Image Setup
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLogOut.delegate = self
        self.fbLoginButtonCell.selectionStyle = UITableViewCellSelectionStyle.none
        //Facebook Profile Image Setup
        self.fbProfileImage.layer.masksToBounds = true
        self.fbProfileImage.layer.cornerRadius = 40
        if((FBSDKAccessToken.current()) != nil){
            self.fbLoggedIn = true
            self.fbProfileImage.isHidden = false
            let profImg = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID!+"/picture?type=large"
            self.fbProfileImage.downloadImage(from: profImg)
        } else {
            self.fbProfileImage.isHidden = true
            self.fbLoggedIn = false
        }
        
    }
    
    //Facebook delegates
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        NSLog("haha result string: %@", result.description)
        if ((error) != nil) {
            // Process error
            //print ("facebook login error")
            self.fbProfileImage.isHidden = true
            self.fbLoggedIn = false
        }
        else if result.isCancelled {
            // Handle cancellations
            //print ("facebook login cancelled")
            self.fbProfileImage.isHidden = true
            self.fbLoggedIn = false
        } else {
            //print ("facebook login complete")
            if((FBSDKAccessToken.current()) != nil){
                self.fbLoggedIn = true
                self.fbProfileImage.isHidden = false
                let profImg = "http://graph.facebook.com/"+FBSDKAccessToken.current().userID!+"/picture?type=large"
                self.fbProfileImage.downloadImage(from: profImg)
            } else {
                self.fbProfileImage.isHidden = true
                self.fbLoggedIn = false
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        NSLog("logged out!!")
        self.fbProfileImage.isHidden = true
        self.performSegue(withIdentifier: "toIntro", sender: self)
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
