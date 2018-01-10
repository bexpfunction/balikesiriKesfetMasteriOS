//
//  uygulamaHakkinda.swift
//  balikesiriKesfet
//
//  Created by xloop on 09/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class uygulamaHakkinda: UIViewController {

    //Buttons
    @IBOutlet weak var openMenuBut: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Reveal View Controller Setup
        openMenuBut.target = self.revealViewController()
        openMenuBut.action = #selector(SWRevealViewController.revealToggle(_:))
        revealViewController().rearViewRevealWidth = 190
        revealViewController().rearViewRevealOverdraw = 200
        //Gesture recognizer for reveal view controller
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
}
