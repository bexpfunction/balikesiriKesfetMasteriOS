//
//  articleCell.swift
//  balikesiriKesfet
//
//  Created by xloop on 13/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class articleCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var abstract: UILabel!
    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
