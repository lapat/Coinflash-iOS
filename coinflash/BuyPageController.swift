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
import SideMenu
import Alamofire
import SVProgressHUD

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
    var DataToBeLoaded = [TCryptoInfo]()
    var DataToBeLoadedwithColor = UIColor()
    
    @IBOutlet weak var CryptoTransationTableView: UITableView!
    // Either Variables
    var EitherTransation = [TCryptoInfo]()
    var EitherTotal : Double = 0.0
    var EitherTotalPrice : Double = 0.0
    
    // Bitcoin Variables
    var BitcoinTransation = [TCryptoInfo]()
    var BitcoinTotal : Double = 0.0
    var BitcoinTotalPrice : Double = 0.0
    
    
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
        // Featch Data From Server
        self.requestCoinFlashFeatchwallet(mobile_secret: "8dkkaiei20kdjkwoeo29ddkskalw82asD!", user_id_mobile: "1", mobile_access_token: "3f506ad810db4baba56493fcd25799")
        
    
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell") as! CryptoTransationCellView
        
        cell.CryptoPrice.text = DataToBeLoaded[indexPath.row].TCryptoInfo_crypto + " / $" + DataToBeLoaded[indexPath.row].TCryptoInfo_price
        cell.CryptoPrice.textColor = self.DataToBeLoadedwithColor
        cell.Date.text = DataToBeLoaded[indexPath.row].TCryptoInfo_Date
        cell.Value.text = DataToBeLoaded[indexPath.row].TCryptoInfo_Value
        cell.CryptoType.text = DataToBeLoaded[indexPath.row].TCryptoInfo_type
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataToBeLoaded.count
    }
    
    @IBAction func changThemeToEther(for button: UIButton){
        btcBtn?.isEnabled  = true
        btcEth?.isEnabled  = false
        LabelCoin?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        boundryCricleImage?.image = UIImage(named: "circleGreen")
        
        // Value assignement
        self.DataToBeLoaded = self.EitherTransation
        self.DataToBeLoadedwithColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        self.CryptoTransationTableView.reloadData()
        self.LabelCoin?.text =  String(self.EitherTotal)
        self.LabelCurrency?.text =  "$ " + String(self.EitherTotalPrice) + " Dollar"
        
    }
    @IBAction func changThemeToBitCoin(for button: UIButton){
        btcBtn?.isEnabled  = false
        btcEth?.isEnabled  = true
        LabelCoin?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        boundryCricleImage?.image = UIImage(named: "circleBlue")
        
        // Value assignement
        self.DataToBeLoaded = self.BitcoinTransation
        self.DataToBeLoadedwithColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        self.CryptoTransationTableView.reloadData()
        self.LabelCoin?.text =  String(self.BitcoinTotal)
        self.LabelCurrency?.text =  "$ " + String(self.BitcoinTotalPrice) + " Dollar"
        
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
    func requestCoinFlashFeatchwallet(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/coinflashtransactions3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            self.BitcoinTransation.removeAll()
            self.EitherTransation.removeAll()
            
            if let array = response.result.value as? NSArray {
                for obj in array {
                    if let dict = obj as? NSDictionary {
                        var singleTransation = TCryptoInfo_global
                        
                        singleTransation?.TCryptoInfo_crypto  = dict.value(forKey: "coinbase_crypto_amount") as! String
                        singleTransation?.TCryptoInfo_price  = dict.value(forKey: "coinbase_total_amount_spent") as! String
                        singleTransation?.TCryptoInfo_Value  = dict.value(forKey: "coinbase_amount_spent_on_crypto") as! String
                        singleTransation?.TCryptoInfo_Date  = dict.value(forKey: "coinbase_time_transaction_will_payout") as! String
                        singleTransation?.TCryptoInfo_type  = dict.value(forKey: "crypto_type") as! String
                        
                        
                        if singleTransation?.TCryptoInfo_Date   != nil{
                            var date: String = singleTransation!.TCryptoInfo_Date
                            var truncated = String(date.characters.dropFirst(5))
                            truncated = String(truncated.characters.dropLast(10))
                            singleTransation?.TCryptoInfo_Date = truncated
                        }
                        if singleTransation?.TCryptoInfo_type != nil{
                            let cryptoType = singleTransation?.TCryptoInfo_type
                            
                            if(cryptoType == "1")
                            {
                                singleTransation?.TCryptoInfo_type = "BTC"
                                self.BitcoinTotal = self.BitcoinTotal + Double(singleTransation!.TCryptoInfo_crypto)!
                                self.BitcoinTotalPrice = self.BitcoinTotalPrice + Double(singleTransation!.TCryptoInfo_price)!
                                self.BitcoinTransation.append(singleTransation!)
                            }
                            else
                            {
                                singleTransation?.TCryptoInfo_type = "ETH"
                                self.EitherTotal = self.EitherTotal + Double(singleTransation!.TCryptoInfo_crypto)!
                                self.EitherTotalPrice = self.EitherTotalPrice + Double(singleTransation!.TCryptoInfo_price)!
                                self.EitherTransation.append(singleTransation!)
                            }
                        }
                        
                        
                       
                    }
                }
            }
            // Loading the data in the Table
            self.changThemeToBitCoin(for: self.btcBtn!)
            SVProgressHUD.dismiss()
            
            
        }
        
        
    }
    
}
