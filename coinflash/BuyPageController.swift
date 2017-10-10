//
//  MainViewController.swift
//  coinflash
//
//  Created by TJ on 9/26/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import Charts
class BuyPageController: UIViewController, UITableViewDataSource ,ChartViewDelegate{
    @IBOutlet weak var btcBtn: UIButton?
    @IBOutlet weak var btcEth: UIButton?
    @IBOutlet weak var CryptRateChart: UIView!
    @IBOutlet weak var LabelCoin: UILabel?
    @IBOutlet weak var LabelCurrency: UILabel?
    @IBOutlet weak var LabelGroth: UILabel?
    @IBOutlet weak var LabelType: UILabel?
    @IBOutlet weak var boundryCricleImage: UIImageView?
    
    @IBOutlet weak var CryptoPriceGraph: LineChartView!
    var Cryptodates:[String]!
    var Cryptoprices:[Double]!
    
    
    @IBOutlet weak var CrypotEitherBitPieChart: PieChartView!
    override func viewDidLoad() {
        
        // Sample Dataset
        Cryptodates = ["9-10","9-10","9-10","9-10","9-10","9-10","9-10","9-10"]
        Cryptoprices = [3110.0,3210.0,3510.0,3410.0,3310.0,3210.0,3110.0,3210.0,3310.0]
        
        //Set Chart Properties
        CryptoPriceGraph.chartDescription?.text = ""
        self.CryptoPriceGraph.rightAxis.drawLabelsEnabled = false
        self.CryptoPriceGraph.leftAxis.labelTextColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        self.CryptoPriceGraph.xAxis.labelTextColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        self.CryptoPriceGraph.legend.enabled = false
        self.CryptoPriceGraph.xAxis.gridColor = UIColor(red: 173/255, green: 194/255, blue: 218/255, alpha: 1)
        self.CryptoPriceGraph.leftAxis.gridColor = UIColor(red: 173/255, green: 194/255, blue: 218/255, alpha: 1)
        self.CryptoPriceGraph.rightAxis.gridColor = UIColor(red: 173/255, green: 194/255, blue: 218/255, alpha: 1)
        self.CryptoPriceGraph.xAxis.axisLineWidth = 1
        self.CryptoPriceGraph.leftAxis.axisLineWidth = 1
        self.CryptoPriceGraph.rightAxis.axisLineWidth = 1
        
        
        self.CryptoPriceGraph.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.CryptoPriceGraph.minOffset = 0
        self.CryptoPriceGraph.xAxis.labelPosition = .bottom
        setCryptochartView(date: Cryptodates, prices: Cryptoprices)
        
        // pie chart for either pricing
        self.CrypotEitherBitPieChart.chartDescription?.text = ""
        self.CrypotEitherBitPieChart.legend.enabled = false
        self.CrypotEitherBitPieChart.holeRadiusPercent = 0
        self.CrypotEitherBitPieChart.transparentCircleColor = UIColor.clear

        
        let type = ["ETH", "BIT"]
        let percentage = [20.0,80.0]
        self.setCryptoPieChart(dataPoints: type, values:percentage)
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    @IBAction func changThemeToEther(for button: UIButton){
        btcBtn?.isEnabled  = true
        btcEth?.isEnabled  = false
        LabelCoin?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        boundryCricleImage?.image = UIImage(named: "circleGreen")
    }
    @IBAction func changThemeToBitCoin(for button: UIButton){
        btcBtn?.isEnabled  = false
        btcEth?.isEnabled  = true
        LabelCoin?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        
        boundryCricleImage?.image = UIImage(named: "circleBlue")
    }
    func setCryptoPieChart(dataPoints: [String], values: [Double]){
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i),y:values[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        pieChartDataSet.drawValuesEnabled = false
        pieChartDataSet.selectionShift = 0
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        CrypotEitherBitPieChart.data = pieChartData
        
        
        var colors: [UIColor] = [UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1), UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)]
        
        pieChartDataSet.colors = colors
        
        
      
        
        
        
    }
    func setCryptochartView(date:[String],prices:[Double]){
        
        var pricesDates: [ChartDataEntry] = []
        var datadays : [String] = []
        for i in 0..<date.count{
            let DataEntry = ChartDataEntry(x: Double(i),y:prices[i])
            pricesDates.append(DataEntry)
            
           }
        let chartDataSet = LineChartDataSet(values: pricesDates, label: nil)
        chartDataSet.drawValuesEnabled = false
        chartDataSet.drawCircleHoleEnabled = false
        chartDataSet.drawCirclesEnabled  = false
        
        chartDataSet.mode = LineChartDataSet.Mode.cubicBezier
        chartDataSet.lineWidth = 3
        chartDataSet.colors = [UIColor(red: 8/255, green: 79/255, blue: 159/255, alpha: 1)]
        
        let chartData = LineChartData(dataSet: chartDataSet)
        
        CryptoPriceGraph.data = chartData
        self.CryptoPriceGraph.xAxis.granularity = 1
        self.CryptoPriceGraph.xAxis.valueFormatter = DefaultAxisValueFormatter(block: { (index, _) -> String in
            return date[Int(index)]
        })
    }
    
}
