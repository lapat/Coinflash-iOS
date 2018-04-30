//
//  ManageChangeHistoryCell.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

class ManageChangeHistoryCell: UITableViewCell, ReusableView, NibLoadableView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(transaction: CCTransaction) {
        let spare = round(num: transaction.spareChange, to: 2)
        valueLabel.text = "\(spare)"
        dateLabel.text = transaction.date
        nameLabel.text = transaction.name
    }
    
}
