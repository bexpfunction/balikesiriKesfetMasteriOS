//
//  uygulamaHakkinda.swift
//  balikesiriKesfet
//
//  Created by xloop on 09/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class uygulamaHakkinda: UIViewController, SWRevealViewControllerDelegate {

    //Buttons
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    @IBOutlet weak var botView: UIView!
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topView.layer.cornerRadius = 5;
        self.topView.layer.borderColor = UIColor.white.cgColor;
        self.topView.layer.borderWidth = 1;
        
        self.botView.layer.cornerRadius = 5;
        self.botView.layer.borderColor = UIColor.white.cgColor;
        self.botView.layer.borderWidth = 1;
        
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 250
        revealViewController().delegate = self
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
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
