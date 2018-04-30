//
//  PortfolioHistoryCell.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

class PortfolioHistoryCell: UITableViewCell, NibLoadableView, ReusableView {
    
    @IBOutlet weak var coinLabel: UILabel!
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var transaction: CoinTransaction? {
        didSet {
            bindData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func bindData() {
        guard let tran = transaction else { return }
        let price = round(num: tran.price, to: 2)
        dollarLabel.text = "$\(price)"
        coinLabel.text = tran.crypto
        dateLabel.text = tran.date
    }
    
}
