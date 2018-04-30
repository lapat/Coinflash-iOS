//
//  PortfolioSummaryCell.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import SwiftyJSON

class PortfolioSummaryCell: UITableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var netGainLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindJson(json: JSON, type: Int) {
        
        var totalPrice: Double = 0
        var totalGainLoss: Double = 0
        
        for i in 0..<CoinType.coins.count {
            let coin = CoinType.coins[i]
            let owned = json[coin.amountOwned].doubleValue
            let now = json[coin.priceRightNowKey].doubleValue
            let spent = json[coin.totalAmountSpentOn].doubleValue
            totalGainLoss += owned * now - spent
            totalPrice += owned * now
        }
        
        // values
        let coin = CoinType.allCoins[type]
        if coin != .all {
            let owned = json[coin.amountOwned].doubleValue
            let now = json[coin.priceRightNowKey].doubleValue
            let spent = json[coin.totalAmountSpentOn].doubleValue
            
            let total_price = owned * now
            let vl = round(num: total_price, to: 2)
            dollarLabel.text = "$ " + vl
            valueLabel.text = "\(owned)"
            
            // gain lost
            totalGainLoss = owned * now - spent
        } else {
            let vl = round(num: totalPrice, to: 2)
            dollarLabel.text = "$ " + vl
            valueLabel.text = ""
        }
        
        if totalGainLoss >= 0 {
            let gainValue = round(num: totalGainLoss, to: 2)
            netGainLabel.text = "+ $\(gainValue) Net Gain"
        } else {
            let gainValue = round(num: -totalGainLoss, to: 2)
            netGainLabel.text = "- $\(gainValue) Net Loss"
        }
    }
}
