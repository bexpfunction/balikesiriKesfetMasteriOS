//
//  bizeYazin.swift
//  balikesiriKesfet
//
//  Created by xloop on 23/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import FBSDKShareKit

class bizeYazin: UIViewController, UITextViewDelegate, SWRevealViewControllerDelegate {

    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var mailTextField: UITextField!
    
    var uName:String?
    var uLastname:String?
    var messageSent:Bool?
    
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
        
        self.sendButton.layer.cornerRadius = 5
        self.sendButton.layer.borderWidth = 1
        self.sendButton.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        
        self.messageTextField.delegate = self
        
        //Keyboard dismiss and textview setup
        mailTextField.layer.cornerRadius = 5
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
//        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        if((self.mailTextField.text!.isEmpty) || (self.messageTextField.text.isEmpty)){
            //Can't send message handler
        } else {
            
            let mailCrypt = self.mailTextField.text!+"xloop"
            let sendUrl1 = "http://app.balikesirikesfet.com/bizeyazin?mail="
            let sendUrl2 = self.mailTextField.text!+"&md5="+mailCrypt.MD5
            let sendUrl3 = "&mesaj="+self.messageTextField.text
            //let sendUrl4 = "(Gönderici:" + self.uName!
            //let sendUrl5 = self.uLastname!
            let rawUrl = sendUrl1 + sendUrl2 + sendUrl3
            let sendFinalUrl = rawUrl.replacingOccurrences(of: " ", with: "+")

            let urlRequest = URLRequest(url: URL(string: sendFinalUrl)!)
            
            let task = URLSession.shared.dataTask(with: urlRequest){(data, response, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                
                if response != nil {
                    print(sendFinalUrl)
                    self.messageSent = true
                }
                
                DispatchQueue.main.async {
                    if self.messageSent == true {
                        _ = self.navigationController?.popViewController(animated: true)
                        //this line goes to root: _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            task.resume()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if((FBSDKAccessToken.current()) != nil){
            let graphRequest:FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"first_name, last_name, email"])
            
            graphRequest.start(completionHandler: { (connection, result, error) -> Void in
                
                if ((error) != nil)
                {
                    print("Error: \(error)")
                }
                else
                {
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    if let emailString = data["email"] as? String{
                        self.mailTextField.text = emailString
                    }
                    if let firstName = data["first_name"] as? String{
                        self.uName = firstName
                    }
                    if let lastName = data["last_name"] as? String{
                        self.uLastname = lastName
                    }
                }
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.messageSent = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        messageTextField.resignFirstResponder()
    }
    
    func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    //SWReveal Delegate
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
        messageTextField.resignFirstResponder()
        let tagId = 42078
        if(position == FrontViewPosition.left) {
            let lock = self.view.viewWithTag(tagId)
            UIView.animate(withDuration: 0.25, animations: {
                lock?.alpha = 0.0
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
