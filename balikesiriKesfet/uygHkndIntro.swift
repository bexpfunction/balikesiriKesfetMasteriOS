//
//  uygHkndIntro.swift
//  balikesiriKesfet
//
//  Created by xloop on 05/02/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class uygHkndIntro: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var botView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        topView.layer.borderColor = UIColor.white.cgColor
        topView.layer.borderWidth = 1
        topView.layer.cornerRadius = 5
        
        botView.layer.borderColor = UIColor.white.cgColor
        botView.layer.borderWidth = 1
        botView.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    


}
