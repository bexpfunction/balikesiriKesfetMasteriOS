//
//  balikesiriKesfetIntro.swift
//  balikesiriKesfet
//
//  Created by xloop on 31/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import FBSDKShareKit

class balikesiriKesfetIntro: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var bbImage: UIImageView!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UIButton!
    @IBOutlet weak var guestEntryButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guestEntryButton.layer.cornerRadius = 5
        guestEntryButton.layer.borderWidth = 1
        guestEntryButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        aboutButton.layer.cornerRadius = 5
        aboutButton.layer.borderWidth = 1
        aboutButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        if((FBSDKAccessToken.current()) != nil){
            loginButton.isHidden = true
            guestEntryButton.isHidden = true
        } else {
            loginButton.isHidden = false
            guestEntryButton.isHidden = true
        }
        
        self.titleImage.alpha = 0
        self.bbImage.alpha = 0
        self.text1.alpha = 0
        self.text2.alpha = 0
        self.guestEntryButton.alpha = 0
        self.loginButton.alpha = 0
        self.text3.alpha = 0
        
        
        
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //animations
        UIView.animate(withDuration: 0.5, animations: {
            self.titleImage.alpha = 1
            }, completion: { (true) in
                self.showBB()
                })
        
        
    }
    
    func showBB(){
        UIView.animate(withDuration: 0.5, animations: {
            self.bbImage.alpha = 1
        }, completion: {(true) in self.showTextsAndButtons()})
    }
    
    func showTextsAndButtons(){
        UIView.animate(withDuration: 0.5, animations: {
            self.text1.alpha = 1
            self.text2.alpha = 1
            self.text3.alpha = 1
            self.guestEntryButton.alpha = 1
            self.loginButton.alpha = 1
        }, completion: {(true) in self.redirectView()})
    }
    
    func redirectView(){
        if((FBSDKAccessToken.current()) != nil){
            print(FBSDKAccessToken.current().userID)
            guestEntryButton.isHidden = true
            self.performSegue(withIdentifier: "toMainNav", sender: self)
        } else {
            guestEntryButton.isHidden = false
        }
    }
    
    //MARK: FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            // Process error
            //print ("facebook login error")
            guestEntryButton.isHidden = false;
        }
        else if result.isCancelled {
            // Handle cancellations
            //print ("facebook login cancelled")
            guestEntryButton.isHidden = false;
        }
        else {
            // Navigate to other view
            //print ("facebook login complete")
            guestEntryButton.isHidden = true;
            //go to main
            self.performSegue(withIdentifier: "toMainNav", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print ("logged out of facebook")
        guestEntryButton.isHidden = false;
    }
    
    
    
}
