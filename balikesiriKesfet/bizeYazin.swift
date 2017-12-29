//
//  bizeYazin.swift
//  balikesiriKesfet
//
//  Created by xloop on 23/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit
import FBSDKShareKit

class bizeYazin: UIViewController, UITextViewDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var mailTextField: UITextField!
    
    var uName:String?
    var uLastname:String?
    var messageSent:Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.messageTextField.delegate = self
        // Do any additional setup after loading the view.
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
}

extension String{
    var MD5:String {
        get{
            let messageData = self.data(using:.utf8)!
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
            
            _ = digestData.withUnsafeMutableBytes {digestBytes in
                messageData.withUnsafeBytes {messageBytes in
                    CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
                }
            }
            
            return digestData.map { String(format: "%02hhx", $0) }.joined()
        }
    }
    /*************************************************
     Example Usage:
         var aa : String?
         aa = "dsadsad"
         var bb = aa?.MD5
         print(bb)
     *************************************************/
}
