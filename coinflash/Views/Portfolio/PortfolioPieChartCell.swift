//
//  PortfolioPieChartCell.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import SwiftyJSON

class PortfolioPieChartCell: UITableViewCell, ReusableView, NibLoadableView {

    var chartView: CustomPieChart?
    @IBOutlet weak var chartContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindJson(json: JSON) {
        
        var totalPrice: Double = 0
        var totalGainLoss: Double = 0
        
        chartView?.removeFromSuperview()
        
        for i in 0..<CoinType.coins.count {
            let coin = CoinType.coins[i]
            let owned = json[coin.amountOwned].doubleValue
            let now = json[coin.priceRightNowKey].doubleValue
            let spent = json[coin.totalAmountSpentOn].doubleValue
            print(owned)
            totalGainLoss += owned * now - spent
            totalPrice += owned * now
        }
        var items = [PNPieChartDataItem]()
        for i in 0..<CoinType.coins.count {
            let coin = CoinType.coins[i]
            let owned = json[coin.amountOwned].doubleValue
            let now = json[coin.priceRightNowKey].doubleValue
            let price = owned * now
            let ratio = totalPrice > 0 ? price/totalPrice : 0.25
            let item = PNPieChartDataItem(value: CGFloat(ratio), color: coin.color)!
            items.append(item)
        }
        let chartV = CustomPieChart(frame: chartContainer.bounds, items: items)!
        chartV.isUserInteractionEnabled = false
        chartV.descriptionTextColor = UIColor.clear
        chartV.descriptionTextShadowColor = UIColor.clear
        chartV.showAbsoluteValues = false
        chartV.showOnlyValues = true
        chartV.hideValues = true
        chartContainer.addSubview(chartV)
        print(chartV.frame)
        chartV.stroke()
        self.chartView = chartV
    }
}

class CustomPieChart: PNPieChart {
    override func recompute() {
        innerCircleRadius = bounds.width/2.8
        
    }
}
