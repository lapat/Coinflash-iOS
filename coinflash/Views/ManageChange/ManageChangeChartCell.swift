//
//  ManageChangeChartCell.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import SwiftyJSON

class ManageChangeChartCell: UITableViewCell, ReusableView, NibLoadableView {

    var coin1ChartView: PNCircleChart?
    @IBOutlet weak var valueLabel: UILabel!
    var coin2ChartView: PNCircleChart?
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var dayLeftLabel: UILabel!
    @IBOutlet weak var chartContainer: UIView!
    
    var buyButtonHandler: ()-> Void = {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        buyButtonHandler()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func bind() {
        buyButton.isEnabled = HelperFunctions.isCoinbaseLoggedIn()
        if let change = ManageChangeHandler.sharedInstance.change  {
            // progress chart
            dayLeftLabel.text = change.invest_on == 1 ? "\(change.dayLeft) DAYS TILL\nNEXT INVESTMENT" : ""
            removeAllCharts()
            if change.invest_on == 1 {
                addCharts(change: change)
            }
        }
        if let pref = ManageChangeHandler.sharedInstance.preference {
            valueLabel.text = pref.invest_on == 1 ? round(num: pref.spare_change_accrued_percent_to_invest, to: 2) : "0.00"
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeAllCharts()
    }
    
    private func removeAllCharts() {
        coin1ChartView?.removeFromSuperview()
        coin2ChartView?.removeFromSuperview()
    }
    
    private func addCharts(change: ChangeModel) {
        let progress = change.timePercent
        let coin1Chart = PNCircleChart(frame: chartContainer.bounds, total: NSNumber(integerLiteral: 1), current: NSNumber(floatLiteral: progress), clockwise: true)!
        let coin2Chart = PNCircleChart(frame: chartContainer.bounds, total: NSNumber(integerLiteral: 1), current: NSNumber(floatLiteral: progress * change.leftPercent), clockwise: true)!
        
        coin1Chart.displayCountingLabel = false
        coin1Chart.backgroundColor = UIColor.clear
        coin1Chart.strokeColor = UIColor.hexColor(hex: "24C6DC")
        coin1Chart.strokeColorGradientStart = UIColor.hexColor(hex: "514A9D")
        
        coin2Chart.displayCountingLabel = false
        coin2Chart.backgroundColor = UIColor.clear
        coin2Chart.strokeColor = UIColor.hexColor(hex: "FFC371")
        coin2Chart.strokeColorGradientStart = UIColor.hexColor(hex: "FF5F6D")
        coin1Chart.isUserInteractionEnabled = false
        coin2Chart.isUserInteractionEnabled = false
        coin1Chart.displayAnimated = false
        coin2Chart.displayAnimated = false
        coin1Chart.isHidden = true
        coin2Chart.isHidden = true
        chartContainer.addSubview(coin1Chart)
        chartContainer.addSubview(coin2Chart)
        coin1Chart.stroke()
        coin2Chart.stroke()
        coin1ChartView = coin1Chart
        coin2ChartView = coin2Chart
        coin1Chart.isHidden = false
        coin2Chart.isHidden = false
    }
}
