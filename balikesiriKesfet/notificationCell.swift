//
//  notificationCell.swift
//  balikesiriKesfet
//
//  Created by xloop on 25/10/2017.
//  Copyright © 2017 Xloop. All rights reserved.
//

import UIKit

class notificationCell: UITableViewCell {

    @IBOutlet weak var nTitle: UILabel!
    @IBOutlet weak var nAbstract: UILabel!
    @IBOutlet weak var nDate: UILabel!
    @IBOutlet weak var cardView: UIView!
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
