//
//  galeri.swift
//  balikesiriKesfet
//
//  Created by xloop on 21/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class galeri: UIViewController, UIScrollViewDelegate {

    var imgUrl : String?
    
    @IBOutlet weak var scrollViewC: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollViewC.minimumZoomScale = 1.0;
        self.scrollViewC.maximumZoomScale = 6.0;
        
        self.scrollViewC.contentSize = self.imgView.frame.size
        self.scrollViewC.delegate = self
        
        self.imgView.downloadImage(from: self.imgUrl!)

        // Do any additional setup after loading the view.
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
    
}
