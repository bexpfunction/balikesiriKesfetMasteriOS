//
//  guestEntryForm.swift
//  balikesiriKesfet
//
//  Created by xloop on 31/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class guestEntryForm: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var guestEntryButton: UIButton!
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //animations
        
        
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        
        if((FBSDKAccessToken.current()) != nil){
            guestEntryButton.isHidden = true
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
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print ("logged out of facebook")
        guestEntryButton.isHidden = false;
    }

}
