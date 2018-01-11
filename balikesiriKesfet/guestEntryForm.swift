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
    @IBOutlet weak var buttonWindow: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonWindow.layer.cornerRadius = 5
        self.buttonWindow.layer.borderWidth = 1
        self.buttonWindow.layer.borderColor = UIColor.white.cgColor
        
        //animations
//        fbLoginButton.layer.cornerRadius = 5
//        fbLoginButton.layer.borderWidth = 1
//        fbLoginButton.layer.borderColor = (UIColor(red: 1, green: 1, blue: 1, alpha: 1) as! CGColor)
        
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.fbLoginButton.delegate = self
        
        self.guestEntryButton.layer.cornerRadius = 5
        self.guestEntryButton.layer.borderWidth = 1
        self.guestEntryButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor

    }
    //MARK: FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if ((error) != nil) {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // Navigate to other view
            //go to main
            performSegue(withIdentifier: "toMain", sender: self)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print ("logged out of facebook")
    }

}
