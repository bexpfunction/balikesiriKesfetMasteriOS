//
//  backTVController.swift
//  balikesiriKesfet
//
//  Created by xloop on 09/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class backTVController: UITableViewController {

    //Facebook image
    @IBOutlet weak var fbProfileImage: UIImageView!

    //Button actions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
}
