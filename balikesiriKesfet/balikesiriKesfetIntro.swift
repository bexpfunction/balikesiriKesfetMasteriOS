//
//  balikesiriKesfetIntro.swift
//  balikesiriKesfet
//
//  Created by xloop on 31/08/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import CoreMotion
import FBSDKShareKit
import FBSDKLoginKit
import CoreLocation

class balikesiriKesfetIntro: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text3: UIButton!
    @IBOutlet weak var guestEntryButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var buttonWindow: UIView!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.guestEntryButton.layer.cornerRadius = 5
        self.guestEntryButton.layer.borderWidth = 1
        self.guestEntryButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        self.aboutButton.layer.cornerRadius = 5
        self.aboutButton.layer.borderWidth = 1
        self.aboutButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        self.buttonWindow.layer.cornerRadius = 5
        self.buttonWindow.layer.borderColor = UIColor.white.cgColor
        self.buttonWindow.layer.borderWidth = 1
        
        if((FBSDKAccessToken.current()) != nil){
            self.loginButton.isHidden = true
            self.guestEntryButton.isHidden = true
        } else {
            self.loginButton.isHidden = false
            self.guestEntryButton.isHidden = true
        }
        
        self.titleImage.alpha = 0
        self.text1.alpha = 0
        //self.guestEntryButton.alpha = 0
        //self.loginButton.alpha = 0
        self.text3.alpha = 0
        self.buttonWindow.alpha = 0

        self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.loginButton.delegate = self
        self.navigationItem.hidesBackButton = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //animations
        UIView.animate(withDuration: 0.5, animations: {
            self.titleImage.alpha = 1
            }, completion: { (true) in
                self.showTextsAndButtons()
                })
        
    }
    
    
    func showTextsAndButtons(){
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonWindow.alpha = 1
            self.text1.alpha = 1
            self.text3.alpha = 1
            //self.guestEntryButton.alpha = 1
            //self.loginButton.alpha = 1
        }, completion: {(true) in self.redirectView()})
    }
    
    func redirectView(){
        if((FBSDKAccessToken.current()) != nil){
            self.guestEntryButton.isHidden = true
            self.performSegue(withIdentifier: "toMainNav", sender: self)
        } else {
            self.guestEntryButton.isHidden = false
        }
    }
    
    
    //MARK: FBSDKLoginButtonDelegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //NSLog("hahahah fb description: %s", loginButton.description)
        if ((error) != nil) {
            // Process error
            //print ("facebook login error")
            self.guestEntryButton.isHidden = false;
            
        }
        else if result.isCancelled {
            // Handle cancellations
            //print ("facebook login cancelled")
            self.guestEntryButton.isHidden = false;
        }
        else {
            // Navigate to other view
            //print ("facebook login complete")
            self.guestEntryButton.isHidden = true;
            
            //FACEBOOK REQ
            var ageRange : String?
            var birthday : String?
            var gender : String?
            var name : String?
            if((FBSDKAccessToken.current()) != nil){
                let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name, age_range, birthday, gender"])
                
                graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                    
                    if ((error) != nil)
                    {
                        print("Error: \(error)")
                    }
                    else
                    {
                        let data:[String:AnyObject] = result as! [String : AnyObject]
                        if let fName = data["first_name"] as? String{
                            name = fName
                            NSLog("\n\name: %@\n\n", name!)
                        }
                        if let aRange = data["age_range"] as? String{
                            ageRange = aRange
                            NSLog("\n\ngender: %@\n\n", aRange)
                        }
                        if let bDay = data["birthday"] as? String{
                            birthday = bDay
                        }
                        if let gen = data["gender"] as? String{
                            gender = gen
                        }
                    }
                })
            }
            // prepare json data
            if(gender != nil && ageRange != nil){
            // create post request
                let url = URL(string: "http://app.balikesirikesfet.com/facebook?json={\"age_range\":"+ageRange!+"\"gender\":"+gender!)!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            // insert json data to the request
            //request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                }
            }

            task.resume()
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //print ("logged out of facebook")
        self.guestEntryButton.isHidden = false;
    }
    
}
