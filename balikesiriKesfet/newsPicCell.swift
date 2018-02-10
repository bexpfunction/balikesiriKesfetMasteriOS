//
//  newsPicCell.swift
//  balikesiriKesfet
//
//  Created by xloop on 18/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class newsPicCell: UICollectionViewCell {
    
    @IBOutlet weak var detailPic: UIImageView!
    
    override func awakeFromNib() {
        self.layer.borderColor = UIColor(red: 35/255, green: 77/255, blue: 110/255, alpha: 1.0).cgColor
        self.layer.borderWidth = 3
    }
}
