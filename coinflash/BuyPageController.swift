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
import Toast_Swift
import NotificationBannerSwift

class BuyPageController: UIViewController, UITableViewDataSource ,ChartViewDelegate{
    @IBOutlet weak var btcBtn: UIButton?
    @IBOutlet weak var btcEth: UIButton?
    @IBOutlet weak var CryptRateChart: UIView!
    @IBOutlet weak var PriceTypeLabel: UILabel!
    @IBOutlet weak var LabelCoin: UILabel?
    @IBOutlet weak var LabelCurrency: UILabel?
    @IBOutlet weak var LabelGroth: UILabel?
    @IBOutlet weak var LabelType: UILabel?
    @IBOutlet weak var boundryCricleImage: UIImageView?
    @IBOutlet weak var ImageArrow: UIImageView?
    
    
    @IBOutlet weak var CryptoPriceGraph: LineChartView!
    var Cryptodates:[String]!
    var Cryptoprices:[Double]!
    var DataToBeLoaded = [TCryptoInfo]()
    var DataToBeLoadedwithColor = UIColor()
    var CurrencyRatePolixCode : String = "USDT_BTC"
    
    // trensation
    
    //var m_mobile_secret = "8dkkaiei20kdjkwoeo29ddkskalw82asD!"
    //var m_user_id = "15"
    //var m_access_token = "fcfba398652f4521aaa878f2305662"
    
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    
    
    
    
    
    @IBOutlet weak var CryptoTransationTableView: UITableView!
    // Either Variables
    var EitherTransation = [TCryptoInfo]()
    var EitherTotal : Double = 0.0
    var EitherTotalPrice : Double = 0.0
    var EitherCryptodates:[String]!
    var EitherCryptoprices:[Double]!
    
    // Bitcoin Variables
    var BitcoinTransation = [TCryptoInfo]()
    var BitcoinTotal : Double = 0.0
    var BitcoinTotalPrice : Double = 0.0
    var BitcoinCryptodates:[String]!
    var BitcoinCryptoprices:[Double]!
    
    //Gain
    var coinbaseAmountSpentOnCrypto : Double = 0.0
    var coinbaseCryptoAmount : Double = 0.0
    var priceOfCryptoToday : Double = 0.0
    
    // Check Gain
    var m_price_right_now_eth : Double = 0.0
    var m_total_amount_spent_on_btc : Double = 0.0
    var m_amount_btc_owned : Double = 0.0
    var m_price_right_now_btc : Double = 0.0
    var m_amount_eth_owned : Double = 0.0
    var m_total_amount_spent_on_eth : Double = 0.0
    
    
    @IBOutlet weak var CrypotEitherBitPieChart: PieChartView!
    override func viewDidLoad() {
        
        // Sample Dataset
        //Cryptodates = ["9-10","9-10","9-10","9-10","9-10","9-10","9-10","9-10"]
        //Cryptoprices = [3110.0,3210.0,3510.0,3410.0,3310.0,3210.0,3110.0,3210.0]
        Cryptodates = []
        Cryptoprices = []
        
        
        BitcoinCryptodates = []
        BitcoinCryptoprices = []
        
        EitherCryptodates = []
        EitherCryptoprices = []
        
        
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
        self.CryptoPriceGraph.noDataText = "Loading"
        
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
        self.requestCoinFlashFeatchwallet(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        self.requestCryptoRates(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        
        // self.LoadCryptoGraphCurrentPriceHistery()
        
        self.getCoinFlashUserInfo()
        if !HelperFunctions.isCoinbaseLoggedIn() && !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "Error!!", subtitle: "Connect your coinbase account and bank to start investing.", style: .danger)
            banner.show()
        }else if !HelperFunctions.isCoinbaseLoggedIn(){
            let banner = NotificationBanner(title: "Error!!", subtitle: "Connect your coinbase account to start investing.", style: .danger)
            banner.show()
        }else if !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "Error!!", subtitle: " Connect your bank to start investing.", style: .danger)
            banner.show()
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if isGraphOptionSelected == true{
            isGraphOptionSelected = false
            
            print(GraphOptionSelected)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        self.PriceTypeLabel.text = "Ethereum price"
        // Value assignement
        self.DataToBeLoaded = self.EitherTransation
        self.DataToBeLoadedwithColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        self.CryptoTransationTableView.reloadData()
        self.LabelCoin?.text =  String(self.m_amount_eth_owned)
        self.LabelCurrency?.text =  "$ " + String(self.m_total_amount_spent_on_eth) + " Dollar"
        self.CurrencyRatePolixCode = "USDT_ETH"
        self.LabelType?.text = "ETH"
        self.Cryptodates = self.EitherCryptodates
        self.Cryptoprices = self.EitherCryptoprices
        setCryptochartView(date: self.Cryptodates, prices: self.Cryptoprices)
        self.loadNetGainEther()
        self.unhideLabels()
        
    }
    @IBAction func changThemeToBitCoin(for button: UIButton){
        btcBtn?.isEnabled  = false
        btcEth?.isEnabled  = true
        LabelCoin?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        boundryCricleImage?.image = UIImage(named: "circleBlue")
        self.PriceTypeLabel.text = "Bitcoin price"
        // Value assignement
        self.DataToBeLoaded = self.BitcoinTransation
        self.DataToBeLoadedwithColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        self.CryptoTransationTableView.reloadData()
        self.LabelCoin?.text =  String(self.m_amount_btc_owned)
        self.LabelCurrency?.text =  "$ " + String(self.m_total_amount_spent_on_btc) + " Dollar"
        self.CurrencyRatePolixCode = "USDT_BTC"
        self.LabelType?.text = "BTC"
        self.Cryptodates = self.BitcoinCryptodates
        self.Cryptoprices = self.BitcoinCryptoprices
        setCryptochartView(date: self.Cryptodates, prices: self.Cryptoprices)
        self.loadNetGainBitcoin()
        self.unhideLabels()
        
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
        
        if date.count == 0{
            return
        }
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
    
    func requestCryptoRates(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let now = NSDate()
        
        //let reducedTime = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)?.dateByAddingUnit(.W, value: -10, toDate: now, options: NSCalendarOptions())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())
        let date = formatter.string(from: fromDate!)
        let dateFormate = formatter.date(from: date)
        let DateToString = formatter.string(from: dateFormate!)
        
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "after" : DateToString
        ]
        SVProgressHUD.show()
        
        
        Alamofire.request("https://coinflashapp.com/coinflashprice/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                self.BitcoinCryptodates.removeAll()
                self.BitcoinCryptoprices.removeAll()
                
                self.EitherCryptodates.removeAll()
                self.EitherCryptoprices.removeAll()
                let count = 0
                if let array = response.result.value as? NSDictionary {
                    if array == nil{
                        self.showErrorToast(message: "Check you internet connection")
                        return
                    }
                    let error = array["error"]
                    if error != nil{
                        
                        self.showErrorToast(message: "Check you internet connection")
                        return
                    }
                    
                    let DataResponseBTC = array["BTC"] as! NSArray
                    let DataResponseETH = array["ETH"] as! NSArray
                    for index in stride(from: (DataResponseBTC.count - 1), to: 0, by: -1){//(DataResponseBTC.count - 1)...0 {
                        let DataDic = DataResponseBTC[index] as? NSDictionary
                        var Date = DataDic!["date"] as! String
                        Date = String(Date.characters.dropFirst(5))
                        let price = DataDic!["price"] as! Double
                        self.BitcoinCryptodates.append(Date)
                        self.BitcoinCryptoprices.append(price)
                        
                    }
                    for index in stride(from: (DataResponseETH.count - 1), to: 0, by: -1){//(DataResponseETH.count - 1)...0 {
                        let DataDic = DataResponseETH[index] as? NSDictionary
                        var Date = DataDic!["date"] as! String
                        Date = String(Date.characters.dropFirst(5))
                        let price = DataDic!["price"] as! Double
                        self.EitherCryptodates.append(Date)
                        self.EitherCryptoprices.append(price)
                        
                    }
                    
                }
                self.changThemeToBitCoin(for: self.btcBtn!)
                //self.changThemeToBitCoin(for: self.btcBtn!)
                SVProgressHUD.dismiss()
            case .failure:
                print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
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
            switch response.result{
            case .success(let value):
                self.BitcoinTransation.removeAll()
                self.EitherTransation.removeAll()
                
                
                let datatransation = response.result.value as! NSDictionary
                
                
                if datatransation["price_right_now_eth"] != nil{
                    self.m_price_right_now_eth = datatransation.value(forKey: "price_right_now_eth") as! Double
                }
                if datatransation["total_amount_spent_on_btc"] != nil{
                    self.m_total_amount_spent_on_btc = datatransation.value(forKey: "total_amount_spent_on_btc") as! Double
                }
                if datatransation["amount_btc_owned"] != nil{
                    self.m_amount_btc_owned = datatransation.value(forKey: "amount_btc_owned") as! Double
                }
                if datatransation["price_right_now_btc"] != nil{
                    self.m_price_right_now_btc = datatransation.value(forKey: "price_right_now_btc") as! Double
                }
                if datatransation["amount_eth_owned"] != nil{
                    self.m_amount_eth_owned = datatransation.value(forKey: "amount_eth_owned") as! Double
                }
                if datatransation["total_amount_spent_on_eth"] != nil{
                    self.m_total_amount_spent_on_eth = datatransation.value(forKey: "total_amount_spent_on_eth") as! Double
                }
                
                let transations = datatransation.value(forKey: "coinflash_transactions") as? NSArray
                if (transations != nil) {
                    for obj in transations! {
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
                self.loadPieChart()
                SVProgressHUD.dismiss()
            case .failure:
                print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    @IBAction func showPopup(_ sender: AnyObject) {
        
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GraphPopUp") as! PopUpViewGraphTypeSelector
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
    }
    func ShowBuyPopUp(){
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyPopUp") as! PopUpViewBuyNowSelector
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
        
    }
    func showErrorToast(message :String){
        
        var style = ToastStyle()
        style.messageColor = .black
        style.backgroundColor = .white
        self.view.makeToast(message, duration: 3.0, position: .bottom, style: style)
        
        
        
    }
    func loadNetGainEther(){
        var GainLoss = m_total_amount_spent_on_eth - m_amount_eth_owned * m_price_right_now_eth
        if GainLoss == 0{
            self.LabelGroth?.isHidden = true
            self.ImageArrow?.isHidden = true
        }
        else{
            self.LabelGroth?.isHidden = false
            self.ImageArrow?.isHidden = false
        }
        
        
        GainLoss = round(num: GainLoss, to: 2)
        
        if GainLoss > 0{
            self.LabelGroth?.text = "$ " + String(GainLoss) + " Net Gain"
            self.ImageArrow?.image = UIImage(named:"gainUp")!
        }
        else{
            GainLoss = GainLoss * -1
            self.LabelGroth?.text = "$ " + String(GainLoss) + " Net Loss"
            self.ImageArrow?.image = UIImage(named:"gainDown")!
        }
    }
    func loadNetGainBitcoin(){
        
        var GainLoss = m_total_amount_spent_on_btc - m_amount_btc_owned * m_price_right_now_btc
        if GainLoss == 0{
            self.LabelGroth?.isHidden = true
            self.ImageArrow?.isHidden = true
        }
        else{
            self.LabelGroth?.isHidden = false
            self.ImageArrow?.isHidden = false
        }
        
        GainLoss = round(num: GainLoss, to: 2)
        if GainLoss > 0{
            self.LabelGroth?.text = "$ " + String(GainLoss) + " Net Gain"
            self.ImageArrow?.image = UIImage(named:"gainUp")!
        }
        else{
            GainLoss = GainLoss * -1
            self.LabelGroth?.text = "$ " + String(GainLoss) + " Net Loss"
            self.ImageArrow?.image = UIImage(named:"gainDown")!
        }
        
    }
    func loadPieChart(){
        
        let price_btc = m_amount_btc_owned * m_price_right_now_btc
        let price_eth = m_amount_eth_owned * m_price_right_now_eth
        if price_btc != 0 || price_eth != 0{
            let ratio_btc = (price_btc / (price_btc + price_eth)) * 100
            let ratio_eth = (price_eth / (price_btc + price_eth)) * 100
            let type = ["ETH", "BIT"]
            
            self.CrypotEitherBitPieChart.isHidden = false
            let percentage = [ratio_eth,ratio_btc]
            self.setCryptoPieChart(dataPoints: type, values:percentage)
            
        }
        else
        {
            let type = ["none"]
            self.CrypotEitherBitPieChart.isHidden = true
            let percentage = [100.0]
            self.setCryptoPieChart(dataPoints: type, values:percentage)
            
        }
        
    }
    func unhideLabels(){
        
        PriceTypeLabel.isHidden = false
        LabelCoin?.isHidden = false
        LabelCurrency?.isHidden = false
        //LabelGroth?.isHidden = false
        LabelType?.isHidden = false
        
    }
    func round(num: Double, to places: Int) -> Double {
        let p = log10(abs(num))
        let f = pow(10, p.rounded() - Double(places) + 1)
        let rnum = (num / f).rounded() * f
        
        return rnum
    }
    
    
    
}
