//
//  backTVController.swift
//  balikesiriKesfet
//
//  Created by xloop on 09/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit
import AVFoundation

class backTVController: UITableViewController, FBSDKLoginButtonDelegate {

    @IBOutlet var pinPopup: UIView!
    var fbLoggedIn : Bool!
    var popupIn : Bool!
    
    //Facebook image
    @IBOutlet weak var fbProfileImage: UIImageView!
    //Facebook button
    @IBOutlet weak var fbLogOut: FBSDKLoginButton!
    //Cells
    @IBOutlet weak var fbLoginButtonCell: UITableViewCell!
    @IBOutlet weak var pinPopupMapBut: UIButton!
    @IBOutlet weak var pinPopupAGBut: UIButton!
    
    let network: NetworkManager = NetworkManager.sharedInstance
    
    
    //Button actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Haberler selected
        if(indexPath.row == 1){
            if(popupIn == true){
                animateOut()
            }
            if(checkConnection(failMessage: "Haberler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "haberlerNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        //AG selected
        if(indexPath.row == 2){
            if(checkConnection(failMessage: "Projeler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.denied {
                    let alert = UIAlertController(title: "UYARI", message: "Artırılmış gerçeklik moduna ulaşabilmeniz için uygulamanın kameraya erişimine izin vermiş olmanız gerekmektedir!", preferredStyle: UIAlertControllerStyle.alert)
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
                    alert.addAction(UIAlertAction(title: "Ayarlar", style: UIAlertActionStyle.default, handler: {
                        action in
                        switch action.style{
                        case .default:
                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                            break
                        case.cancel:
                            break
                        case.destructive:
                            break
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(3, forKey: "pinCategorySelection")
                    animateIn()
                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //let controller = storyboard.instantiateViewController(withIdentifier: "agVC")
                    //self.navigationController?.pushViewController(controller, animated: true)
                }
                
            }
//            if(checkConnection(failMessage: "Artırılmış gerçeklik moduna ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
//                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.denied {
//                    let alert = UIAlertController(title: "UYARI", message: "Artırılmış gerçeklik moduna ulaşabilmeniz için uygulamanın kameraya erişimine izin vermiş olmanız gerekmektedir!", preferredStyle: UIAlertControllerStyle.alert)
//                    alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {
//                        action in
//                        switch action.style{
//                        case .default:
//                            break
//                        case.cancel:
//                            break
//                        case.destructive:
//                            break
//                        }
//                    }))
//                    alert.addAction(UIAlertAction(title: "Ayarlar", style: UIAlertActionStyle.default, handler: {
//                        action in
//                        switch action.style{
//                        case .default:
//                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
//                            break
//                        case.cancel:
//                            break
//                        case.destructive:
//                            break
//                        }
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                    let controller = storyboard.instantiateViewController(withIdentifier: "agNavC")
//                    self.revealViewController().pushFrontViewController(controller, animated: true)
//                }
//            }
        }
        
        if(indexPath.row == 3){
            if(checkConnection(failMessage: "Kültürel Etkinlikler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.denied {
                    let alert = UIAlertController(title: "UYARI", message: "Artırılmış gerçeklik moduna ulaşabilmeniz için uygulamanın kameraya erişimine izin vermiş olmanız gerekmektedir!", preferredStyle: UIAlertControllerStyle.alert)
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
                    alert.addAction(UIAlertAction(title: "Ayarlar", style: UIAlertActionStyle.default, handler: {
                        action in
                        switch action.style{
                        case .default:
                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                            break
                        case.cancel:
                            break
                        case.destructive:
                            break
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(1, forKey: "pinCategorySelection")
                    animateIn()
                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //let controller = storyboard.instantiateViewController(withIdentifier: "agVC")
                    //self.navigationController?.pushViewController(controller, animated: true)
                }
                
            }
        }
        
        //Duyuru selected
        if(indexPath.row == 4){
            if(checkConnection(failMessage: "Görülmesi Gereken Yerler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.denied {
                    let alert = UIAlertController(title: "UYARI", message: "Artırılmış gerçeklik moduna ulaşabilmeniz için uygulamanın kameraya erişimine izin vermiş olmanız gerekmektedir!", preferredStyle: UIAlertControllerStyle.alert)
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
                    alert.addAction(UIAlertAction(title: "Ayarlar", style: UIAlertActionStyle.default, handler: {
                        action in
                        switch action.style{
                        case .default:
                            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
                            break
                        case.cancel:
                            break
                        case.destructive:
                            break
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(2, forKey: "pinCategorySelection")
                    animateIn()
                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    //let controller = storyboard.instantiateViewController(withIdentifier: "agVC")
                    //self.navigationController?.pushViewController(controller, animated: true)
                }
                
            }
            //            if(checkConnection(failMessage: "Duyurular sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
            //                let storyboard = UIStoryboard(name: "Main", bundle: nil)
            //                let controller = storyboard.instantiateViewController(withIdentifier: "duyuruNavC")
            //                self.revealViewController().pushFrontViewController(controller, animated: true)
            //            }
        }
        
        //Harita selected
        if(indexPath.row == 5){
            if(popupIn == true){
                animateOut()
            }
            if(checkConnection(failMessage: "Harita sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "haritaNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        
        if(indexPath.row == 6) {
            if(popupIn == true){
                animateOut()
            }
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
        
        if(indexPath.row == 7){
            if(popupIn == true){
                animateOut()
            }
            let url = URL(string: "http://www.balikesir.bel.tr")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                //If you want handle the completion block than
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Open url : \(success)")
                })
            }
        }
        
        if(indexPath.row == 8){
            if(popupIn == true){
                animateOut()
            }
            if(checkConnection(failMessage: "Balıkesir Büyükşehir Belediyesi Facebook sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "bbbFacebookNavC")
                self.revealViewController().pushFrontViewController(controller, animated: true)
            }
        }
        
        if(indexPath.row == 9){
            if(popupIn == true){
                animateOut()
            }
        }
        
        if(indexPath.row == 10){
            if(popupIn == true){
                animateOut()
            }
            exit(0)
        }
        
        if(indexPath.row == 11){
            if(popupIn == true){
                animateOut()
            }
        }
        
        if(indexPath.row == 12){
            if(popupIn == true){
                animateOut()
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
        pinPopupAGBut.layer.cornerRadius = 5
        pinPopupAGBut.layer.borderWidth = 1
        pinPopupAGBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        pinPopupMapBut.layer.cornerRadius = 5
        pinPopupMapBut.layer.borderWidth = 1
        pinPopupMapBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        popupIn = false
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
    
    @IBAction func agPopupBut(_ sender: Any) {
        animateOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "agNavC")
        self.revealViewController().pushFrontViewController(controller, animated: true)
    }
    @IBAction func mapPopupBut(_ sender: Any) {
        animateOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "haritaNavC")
        self.revealViewController().pushFrontViewController(controller, animated: true)
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
    
    //Popup animations
    func animateIn() {
        self.popupIn = true
        self.pinPopup.layer.cornerRadius = 5
        self.pinPopup.layer.borderWidth = 1
        self.pinPopup.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        let wndow = UIApplication.shared.keyWindow;
        
        wndow?.addSubview(pinPopup)
        pinPopup.center = (wndow?.center)!
        
        pinPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        pinPopup.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.pinPopup.alpha = 1
            self.pinPopup.transform = CGAffineTransform.identity
        })
    }
    
    func animateOut() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.pinPopup.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.pinPopup.alpha = 0
            
        }, completion: {
            (success:Bool) in
            self.pinPopup.removeFromSuperview()
            self.popupIn = false
        })
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if(popupIn == true){
//            let touch = touches.first
//            guard let location = touch?.location(in: self.pinPopup) else { return }
//            if !pinPopup.frame.contains(location) {
//                print("Tapped outside the view")
//                animateOut()
//            }else {
//                print("Tapped inside the view")
//            }
//        }
//    }
    
    
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
