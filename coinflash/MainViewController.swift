//
//  MainViewController.swift
//  coinflash
//
//  Created by TJ on 9/26/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import Alamofire
import SVProgressHUD
import SwiftyJSON
import NotificationBannerSwift

// MainView Class
class MainViewController: UIViewController, UITableViewDataSource{
    @IBOutlet weak var LabelCurrency: UILabel?
    @IBOutlet weak var LabelGroth: UILabel?
    @IBOutlet weak var LabelType: UILabel?
    @IBOutlet weak var LabelSinceChange: UILabel?
    @IBOutlet weak var LabelChange: UILabel?
    @IBOutlet weak var LabelChangeTip: UILabel?
    @IBOutlet weak var LabelBitcoin: UILabel?
    @IBOutlet weak var LabelBitcoinInvestmentRate: UILabel?
    @IBOutlet weak var LabelEtherInvestmentRate: UILabel?
    @IBOutlet weak var SliderinvestmentRateDecider: UISlider?
    @IBOutlet weak var ccTransationTableView: UITableView?
    
    var cctransations = [cctransaction_global]
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    
    
    var m_spare_change_accrued_percent_to_invest : Double = 0.0
    var m_cap : Double = 0.0
    var m_percent_to_invest : Double = 0.0
    var m_how_often : Double = 0.0
    var m_spare_change_accrued : Double = 0.0
    var m_btc_to_invest : Double = 0.0
    var m_invest_on : Double = 0.0
    var m_btc_percentage: Double = 0.0
    
    var coinflashUser3ResponseObject: JSON!
    var cctransaction2ResponseObject: JSON!
    
    
    @IBAction func InvestmentRateSlider(_ sender: UISlider) {
        var rate: Float = SliderinvestmentRateDecider!.value
        rate = Float(Int(rate))
        let dollarsToInvest = m_spare_change_accrued_percent_to_invest
        let btcRate = 100 - rate
        let ethRate = rate
        
        self.LabelBitcoinInvestmentRate?.text = String(format:"%.0f", btcRate) + "%"
        self.LabelEtherInvestmentRate?.text = String(format:"%.0f", (ethRate)) + "%"
        
        let btcColor = UIColor(red: 8/255.0, green: 79/255.0, blue: 159/255.0, alpha: 1.0)
        let ethColor = UIColor(red: 110/255.0, green: 176/255.0, blue: 56/255.0, alpha: 1.0)
        let color = UIColor.blend(color1: btcColor, intensity1: (CGFloat(1.0 - rate/100.0)), color2: ethColor, intensity2: CGFloat(rate/100.0))
        //print("Rate: \(rate) && btcIntensity : \(1.0 - rate/100.0) && intensity2: \(rate/100.0)")
        sender.thumbTintColor = color
        sender.minimumTrackTintColor = color
        sender.maximumTrackTintColor = color
        
        // Set the ether and bitcoin rate in the top label with respect to the percentage
        let dollarToInvestInBTC = Float(dollarsToInvest)*Float(btcRate/100.0)
        let dollarToInvestETH = Float(dollarsToInvest)*Float((ethRate)/100.0)
        self.LabelChange?.text = String(format: "$ %.2f / %.2f", dollarToInvestInBTC,dollarToInvestETH)
        
        /// Set the mutable attributed string for the top label showing dollars
        let prefixString: NSAttributedString = NSAttributedString(string: "$ ", attributes: [NSForegroundColorAttributeName : color])
        let btcString: NSAttributedString = NSAttributedString(string: String(format: "%.2f", dollarToInvestInBTC), attributes: [NSForegroundColorAttributeName : btcColor])
        let slashString: NSAttributedString = NSAttributedString(string: " / ", attributes: [NSForegroundColorAttributeName : color])
        let suffixString: NSAttributedString = NSAttributedString(string: "$ ", attributes: [NSForegroundColorAttributeName : color])
        let ethStirng: NSAttributedString = NSAttributedString(string: String(format: "%.2f", dollarToInvestETH), attributes: [NSForegroundColorAttributeName : ethColor])
        let dollarLabelString : NSMutableAttributedString = NSMutableAttributedString()
        dollarLabelString.append(prefixString)
        dollarLabelString.append(btcString)
        dollarLabelString.append(slashString)
        dollarLabelString.append(suffixString)
        dollarLabelString.append(ethStirng)
        self.LabelChange?.attributedText = dollarLabelString
    }
    
    @IBAction func OnInvestmentRateSliderRelease(_ sender: Any) {
        var rate: Float = SliderinvestmentRateDecider!.value
        rate = Float(Int(rate))
        let ethRate =  rate
        UpdateSlideVaueToServer(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token,SliderValue: Int(ethRate))
        //print("element Released")
    }
    
    override func viewDidLoad() {
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.default.menuDismissOnPush = true
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuParallaxStrength = 3
        NotificationCenter.default.addObserver(self, selector: #selector(didSuccessfullyBuyCoins(handleNotification:)), name: NSNotification.Name.onSuccessfulPurchaseOfCoins, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        self.requestCoinflashUser3Values(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    func updateViewInvestmentInformation(){
        self.LabelChangeTip?.text = String(Int(self.m_percent_to_invest)) + "% of Your Change Will Be Invested Every Monday"
        self.LabelChange?.text = "$ " + String(self.m_spare_change_accrued_percent_to_invest)
        var bitrate = Double(0)
        
        bitrate = m_btc_percentage
        let etherRate = 100 - bitrate
        
        self.LabelEtherInvestmentRate?.text = String(Int(etherRate)) + "%"
        self.LabelBitcoinInvestmentRate?.text = String(Int(bitrate)) + "%"
        self.SliderinvestmentRateDecider?.value = Float(etherRate)
        self.InvestmentRateSlider(self.SliderinvestmentRateDecider!)
        
        // Set the ether and bitcoin rate in the top label with respect to the percentage
        //let dollarToInvestInBTC = Float(self.m_spare_change_accrued_percent_to_invest)*Float(etherRate/100.0)
        //let dollarToInvestETH = Float(self.m_spare_change_accrued_percent_to_invest)*Float(bitrate/100.0)
        //self.LabelChange?.text = String(format: "$ %.2f / %.2f", dollarToInvestInBTC,dollarToInvestETH)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell") as! ccTransationCellView
        
        cell.Name.text = cctransations[indexPath.row]?.cctransaction_name
        cell.Date.text = cctransations[indexPath.row]?.cctransaction_date
        cell.Price.text = cctransations[indexPath.row]?.cctransaction_amount
        cell.invested.text = cctransations[indexPath.row]?.cctransaction_invested
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cctransations.count
    }
    
    func requestCoinFlashFeatchccTransations(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        SVProgressHUD.show()
        
        
        Alamofire.request("https://coinflashapp.com/cctransactions2/", method: HTTPMethod.post, parameters: parameters,headers: headers)
            .responseJSON { response in
                switch response.result{
                case .success(let value):
                    do {
                        if response.result.value == nil {
                            HelperFunctions.showToast(withString: "Check Your Internet Connection", onViewController: self)
                            SVProgressHUD.dismiss()
                        }
                        let data = response.result.value as! [String: Any]
                        if data["cc_transactions_array"] == nil
                        {
                            SVProgressHUD.dismiss()
                            return
                        }
                        let TransationArray = data["cc_transactions_array"] as! [[String: Any]]
                        let user_preferences = data["user_preferences"] as! [String: Any]
                        if user_preferences["spare_change_accrued_percent_to_invest"] != nil{
                            self.m_spare_change_accrued_percent_to_invest = Double(user_preferences["spare_change_accrued_percent_to_invest"] as! String)!
                            //self.m_spare_change_accrued = Double(round(100 * self.m_spare_change_accrued_percent_to_invest)/100)
                        }
                        if user_preferences["percent_to_invest"] != nil{
                            self.m_percent_to_invest = Double(user_preferences["percent_to_invest"] as! String)!
                            
                        }
                        if user_preferences["how_often"] != nil{
                            self.m_how_often = Double(user_preferences["how_often"] as! String)!
                        }
                        if user_preferences["spare_change_accrued"] != nil{
                            self.m_spare_change_accrued = Double(user_preferences["spare_change_accrued"] as! String)!
                        }
                        if user_preferences["btc_to_invest"] != nil{
                            self.m_btc_to_invest = user_preferences["btc_to_invest"] as! Double
                            self.m_btc_to_invest = Double(round(100 * self.m_btc_to_invest)/100)
                            
                        }
                        if user_preferences["invest_on"] != nil{
                            self.m_invest_on = Double(user_preferences["invest_on"] as! String)!
                        }
                        
                        if user_preferences["btc_percentage"] != nil{
                            self.m_btc_percentage = user_preferences["btc_percentage"] as! Double
                        }
                        
                        
                        self.cctransations.removeAll()
                        /// Bound error occuring check
                        if TransationArray.count > 0{
                            for index in 0...TransationArray.count - 1 {
                                let transation = TransationArray[index]
                                var singleTransation = cctransaction_global
                                if transation["cctransaction_name"] != nil{
                                    singleTransation?.cctransaction_name = transation["cctransaction_name"] as! String
                                }
                                if transation["cctransaction_date"] != nil{
                                    var date: String = transation["cctransaction_date"] as! String
                                    let truncated = String(date.characters.dropFirst(5))
                                    singleTransation?.cctransaction_date = truncated
                                }
                                if transation["cctransaction_amount"] != nil{
                                    singleTransation?.cctransaction_amount = transation["cctransaction_amount"] as! String!
                                }
                                if transation["coinbase_transaction_id"] != nil{
                                    singleTransation?.cctransaction_coinbase_transaction_id = transation["coinbase_transaction_id"] as! String
                                    singleTransation?.cctransaction_invested = "invested"
                                }
                                else{
                                    singleTransation?.cctransaction_invested = "Not invested"
                                }
                                self.cctransations.append(singleTransation)
                                
                            }
                        }
                        
                        self.ccTransationTableView?.reloadData()
                        self.updateViewInvestmentInformation()
                        SVProgressHUD.dismiss()
                        
                    }catch {
                        
                        SVProgressHUD.dismiss()
                    }
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
    }
    
    
    
    
    func showConfirmationDialogBox(title : String , Message : String)
    {
        let alert = UIAlertController(title: title, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func UpdateSlideVaueToServer(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,SliderValue :Int){
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "slider_value" : "\(SliderValue)"
            
        ]
        SVProgressHUD.show(withStatus: "Updating Values")
        
        Alamofire.request("https://coinflashapp.com/coinflashuser3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                let data = response.result.value as? NSDictionary
                let SliderUpdated = data?.value(forKey: "success")
                //let data = response.result.value as! [String: String]
                if SliderUpdated != nil
                {
                    // Update the global vars with respect to the change:
                    self.m_btc_percentage = Double(SliderValue)
                }
                SVProgressHUD.dismiss()
            case .failure:
                print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func requestCoinflashUser3Values(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/coinflashuser3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(response.result.value)
                self.coinflashUser3ResponseObject = json[0]
                globalCoinflashUser3ResponseValue = self.coinflashUser3ResponseObject
                SVProgressHUD.dismiss()
            case .failure:
                print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    //MARK: - Buy Now implementation
    @IBAction func didTapOnBuyNowButton(){
        /// checking if there is a coinbase account with allow_buy = true
        var allow_buy = false
        if coinflashUser3ResponseObject["coinbase_accounts"].arrayValue != nil{
            let accounts = coinflashUser3ResponseObject["coinbase_accounts"]
            for (index,subJson):(String, JSON) in accounts {
                if subJson["allow_buy"].bool == true{
                    allow_buy = true
                }
            }
        }else{
            
        }
        
        // if allow buy true then else show error
        if allow_buy == true{
            //HelperFunctions.showToast(withString: "Buying is allowed", onViewController: self)
            let dollars = m_spare_change_accrued_percent_to_invest
            let dollarsToBuyBtc = m_spare_change_accrued_percent_to_invest * m_btc_percentage/100
            let dollarsToBuyEther = m_spare_change_accrued_percent_to_invest - dollarsToBuyBtc
            if dollarsToBuyEther < 3 || dollarsToBuyBtc < 3{
                HelperFunctions.showToast(withString: "Minimum amount required to buy any cryptocurrency is $3. Kindly review!", onViewController: self)
            }else{
                //self.requestServerToBuy(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, dollars: dollars)
                let popUpView: PopUpViewBuyNowSelector = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyPopUpView") as! PopUpViewBuyNowSelector
                // put the vars for showing the view
                popUpView.dollars = dollars
                popUpView.btcToBuyValueInDollars = dollarsToBuyBtc
                popUpView.etherToBuyValueInDollars = dollarsToBuyEther
                
                // Setting the transition settings
                popUpView.modalPresentationStyle = .overCurrentContext
                popUpView.modalTransitionStyle = .crossDissolve
                self.present(popUpView, animated: true, completion: nil)
            }
        }else{
            HelperFunctions.showToast(withString: "Configure your coinbase account in settings to buy items", onViewController: self)
        }
    }
    
    /// Handles the buy notification which is called when the buy is successfull
    func didSuccessfullyBuyCoins(handleNotification notificaiton: NSNotification){
        let banner = NotificationBanner(title: "Success", subtitle: "You successfully bought cyrptocurrency using your spare change.", style: .success)
        banner.show()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier  == "generalSettingsSegue"{
            if globalCoinflashUser3ResponseValue == JSON.null{
                self.requestCoinflashUser3Values(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
                HelperFunctions.showToast(withString: "Error! Trying to reload Data", onViewController: self)
                return false
            }
        }
        return true
    }
    
}

