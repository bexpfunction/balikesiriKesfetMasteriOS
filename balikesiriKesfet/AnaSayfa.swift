//
//  AnaSayfa.swift
//  balikesiriKesfet
//
//  Created by xloop on 08/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit
import AVFoundation

class AnaSayfa: UIViewController, SWRevealViewControllerDelegate {
    
    //Buttons
    @IBOutlet weak var haberlerBut: UIButton!
    @IBOutlet weak var haritaBut: UIButton!
    @IBOutlet weak var duyurularBut: UIButton!
    @IBOutlet weak var uygHakkindaBut: UIButton!
    @IBOutlet weak var bizeYazinBut: UIButton!
    @IBOutlet weak var webBut: UIButton!
    @IBOutlet weak var quitBut: UIButton!
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var agPopupBut: UIButton!
    @IBOutlet weak var mapPopupBut: UIButton!
    
    //Views
    @IBOutlet weak var agbView: UIView!
    @IBOutlet weak var haberlerBView: UIView!
    @IBOutlet weak var haritaBView: UIView!
    @IBOutlet weak var duyuruBView: UIView!
    @IBOutlet weak var webBView: UIView!
    @IBOutlet weak var bizeYazinBView: UIView!
    @IBOutlet var pinPopup: UIView!
    
    let network: NetworkManager = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(-1, forKey: "pinCategorySelection")
        
        //Buttons and view setup
        agbView.layer.cornerRadius = 5
        agbView.layer.borderWidth = 1
        agbView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        haberlerBView.layer.cornerRadius = 5
        haberlerBView.layer.borderWidth = 1
        haberlerBView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        haritaBView.layer.cornerRadius = 5
        haritaBView.layer.borderWidth = 1
        haritaBView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        duyuruBView.layer.cornerRadius = 5
        duyuruBView.layer.borderWidth = 1
        duyuruBView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        webBView.layer.cornerRadius = 5
        webBView.layer.borderWidth = 1
        webBView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        bizeYazinBView.layer.cornerRadius = 5
        bizeYazinBView.layer.borderWidth = 1
        bizeYazinBView.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        webBut.layer.cornerRadius = 5
        webBut.layer.borderWidth = 1
        webBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        quitBut.layer.cornerRadius = 5
        quitBut.layer.borderWidth = 1
        quitBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        uygHakkindaBut.layer.cornerRadius = 5
        uygHakkindaBut.layer.borderWidth = 1
        uygHakkindaBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        agPopupBut.layer.cornerRadius = 5
        agPopupBut.layer.borderWidth = 1
        agPopupBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        mapPopupBut.layer.cornerRadius = 5
        mapPopupBut.layer.borderWidth = 1
        mapPopupBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        pinPopup.layer.cornerRadius = 5
        pinPopup.layer.borderWidth = 1
        pinPopup.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 240
        revealViewController().rearViewRevealOverdraw = 300
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        revealViewController().tapGestureRecognizer().isEnabled = true
        revealViewController().delegate = self

    }
    
    //Button actions
    @IBAction func haberlerClick(_ sender: UIButton) {
        if(checkConnection(failMessage: "Haberler sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "haberlerVC")
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func agModuClick(_ sender: UIButton) {
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
        //        let url = URL(string: "http://www.balikesir.bel.tr")!
        //        if UIApplication.shared.canOpenURL(url) {
        //            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        //            //If you want handle the completion block than
        //            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
        //                print("Open url : \(success)")
        //            })
        //        }
    }
    
    @IBAction func haritaClick(_ sender: UIButton) {
        if(checkConnection(failMessage: "Harita sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "haritaVC")
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func duyuruClicked(_ sender: UIButton) {
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
//        if(checkConnection(failMessage: "Duyurular sayfasına ulaşabilmeniz için internet bağlantınızın aktif olması gerekmektedir!")) {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let controller = storyboard.instantiateViewController(withIdentifier: "duyuruVC")
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
    }
    
    @IBAction func webButClicked(_ sender: UIButton) {
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
        
    }
    
    @IBAction func bizeYazClicked(_ sender: UIButton) {
        if(FBSDKAccessToken.current() == nil) {
            let alert = UIAlertController(title: "UYARI", message: "Mesaj gönderebilmek için mevcut Facebook hesabınız ile giriş yapmanız gerekmektedir.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: UIAlertActionStyle.default, handler: {
                action in
                switch action.style{
                case .default:
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "introVC")
                    self.present(controller, animated:true, completion:nil)
                    break
                case.cancel:
                    break
                case.destructive:
                    break
                }
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "bizeYazNavC")
            self.revealViewController().pushFrontViewController(controller, animated: true)
        }
    }
    
    @IBAction func uygHkClicked(_ sender: UIButton) {
                let url = URL(string: "http://www.balikesir.bel.tr")!
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    //If you want handle the completion block than
                    UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                        print("Open url : \(success)")
                    })
                }
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "uygHkVC")
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func toAgModeGlobal(_ sender: Any) {
        animateOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "agVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func toMapModeGlobal(_ sender: Any) {
        animateOut()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "haritaVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func quitClicked(_ sender: UIButton) {
        exit(0)
    }

    
    //Popup animations
    func animateIn() {
        self.view.addSubview(pinPopup)
        pinPopup.center = self.view.center
        
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
        })
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
    
    //Delegate functions
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
