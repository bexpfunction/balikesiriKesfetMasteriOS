//
//  pinListCell.swift
//  balikesiriKesfet
//
//  Created by xloop on 05/01/2018.
//  Copyright © 2018 Xloop. All rights reserved.
//

import UIKit

class pinListCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var pinTitleLabel: UILabel!
    @IBOutlet weak var openInfoBut: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.selectedBackgroundView?.backgroundColor = UIColor(red: 54/255, green: 105/255, blue: 152/255, alpha: 1.0)
        openInfoBut.layer.cornerRadius = 5
        openInfoBut.layer.borderColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        openInfoBut.layer.borderWidth = 1
        // Initialization code
    }
}
