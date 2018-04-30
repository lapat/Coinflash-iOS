//
//  PortfolioPriceCell.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import Charts
import SwiftyJSON

class PortfolioPriceCell: UITableViewCell, NibLoadableView, ReusableView {

    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        
        lineChart.rightAxis.drawLabelsEnabled = true
        lineChart.rightAxis.labelTextColor = UIColor.hexColor(hex: "BDBDBD")
        lineChart.xAxis.labelTextColor = UIColor.hexColor(hex: "BDBDBD")
        lineChart.legend.enabled = false
        lineChart.xAxis.gridColor = UIColor.clear
        lineChart.rightAxis.gridColor = UIColor.clear
        lineChart.leftAxis.gridColor = UIColor.clear
        lineChart.noDataText = "Loading..."
        lineChart.xAxis.labelPosition = .bottom
        lineChart.leftAxis.enabled = false
        lineChart.minOffset = 17
        lineChart.chartDescription?.text = ""
        lineChart.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindJson(json: JSON, coin: CoinType) {
        let selectedCoin = coin == .all ? .btc : coin
        let array = json[selectedCoin.name].arrayValue
        
        var dates = [String]()
        var prices = [Double]()
        for subJson in array {
            let date = subJson["date"].stringValue
            dates.append(String(date.characters.dropFirst(5)))
            prices.append(subJson["price"].doubleValue)
        }
        drawChart(datetags: dates, prices: prices, coin: selectedCoin)
    }
    
    private func drawChart(datetags:[String],prices:[Double], coin: CoinType) {
        var pricesDates: [ChartDataEntry] = []
        for i in 0..<datetags.count {
            let entry = ChartDataEntry(x: Double(i), y: prices[i])
            pricesDates.append(entry)
        }
        let set = LineChartDataSet(values: pricesDates, label: nil)
        set.drawValuesEnabled = false
        set.drawCirclesEnabled = false
        set.drawCircleHoleEnabled = false
        set.mode = .cubicBezier
        set.lineWidth = 3
        let lineColor = coin.color
        set.colors = [lineColor]
        
        let gradientColors: [CGColor] = [UIColor.white.cgColor, lineColor.withAlphaComponent(0.17).cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        set.fillAlpha = 1
        set.fill = Fill(linearGradient: gradient, angle: 90)
        set.drawFilledEnabled = true
        
        let data = LineChartData(dataSet: set)
        lineChart.data = data
        
        lineChart.xAxis.granularity = 1
        lineChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (index, _) -> String in
            return datetags[Int(index)]
        })
    }
}
