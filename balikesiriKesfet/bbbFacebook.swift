//
//  bbbFacebook.swift
//  balikesiriKesfet
//
//  Created by xloop on 23/03/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class bbbFacebook: UIViewController, UIWebViewDelegate, SWRevealViewControllerDelegate {

    
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var bbbFbWebView: UIWebView!
    
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
        
        
        let url = NSURL(string: "https://www.facebook.com/balikesirbld/posts/")
        let request = NSURLRequest(url: url! as URL)
        
        self.bbbFbWebView.delegate = self
        self.bbbFbWebView.loadRequest(request as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
