//
//  CardSettingCell.swift
//  CoinFlash
//
//  Created by robert pham on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit

class CardSettingCell: UITableViewCell, NibLoadableView, ReusableView {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        iconView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
