//
//  AnaSayfa.swift
//  balikesiriKesfet
//
//  Created by xloop on 08/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class AnaSayfa: UIViewController {

    //Buttons
    @IBOutlet weak var haberlerBut: UIButton!
    @IBOutlet weak var haritaBut: UIButton!
    @IBOutlet weak var duyurularBut: UIButton!
    @IBOutlet weak var uygHakkindaBut: UIButton!
    @IBOutlet weak var bizeYazinBut: UIButton!
    @IBOutlet weak var webBut: UIButton!
    @IBOutlet weak var quitBut: UIButton!
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    
    //Views
    @IBOutlet weak var agbView: UIView!
    @IBOutlet weak var haberlerBView: UIView!
    @IBOutlet weak var haritaBView: UIView!
    @IBOutlet weak var duyuruBView: UIView!
    @IBOutlet weak var webBView: UIView!
    @IBOutlet weak var bizeYazinBView: UIView!
    
    //ViewControllers
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 200
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }

    //Button actions
    @IBAction func haberlerClick(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "haberlerVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func agModuClick(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "agVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func haritaClick(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "haritaVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func duyuruClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "duyuruVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func webButClicked(_ sender: UIButton) {
        let url = URL(string: "http://www.balikesir.bel.tr")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            //If you want handle the completion block than
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open url : \(success)")
            })
        }
    }
    
    @IBAction func bizeYazClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "bizeYazVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func uygHkClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "uygHkVC")
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func quitClicked(_ sender: UIButton) {
        exit(0)
    }

}
