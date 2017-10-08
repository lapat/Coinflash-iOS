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
        Cryptodates = ["9-10","9-10","9-10","9-10","9-10","9-10","9-10","9-10","9-10"]
        Cryptoprices = [3110.0,3210.0,3510.0,3410.0,3310.0,3210.0,3110.0,3210.0,3310.0,3410.0]
        
        
        //Set Chart Properties
        CryptoPriceGraph.chartDescription?.text = ""
        self.CryptoPriceGraph.borderColor = UIColor.blue
        
        self.CryptoPriceGraph.rightAxis.drawLabelsEnabled = false
        self.CryptoPriceGraph.leftAxis.labelTextColor = UIColor.blue
        
        self.CryptoPriceGraph.legend.enabled = false
        self.CryptoPriceGraph.legend.enabled = false
        self.CryptoPriceGraph.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.CryptoPriceGraph.minOffset = 0
        
        self.CryptoPriceGraph.xAxis.labelPosition = .bottom
        
        setCryptochartView(date: Cryptodates, prices: Cryptoprices)
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
        chartDataSet.lineWidth = 4
        
        
        let chartData = LineChartData(dataSet: chartDataSet)
        CryptoPriceGraph.data = chartData
        
        
        
    }
    
}
