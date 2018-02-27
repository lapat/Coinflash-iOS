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
    @IBOutlet weak var ccTransationTableView: UITableView?
    @IBOutlet weak var settingsPageButton: UIButton!
    @IBOutlet weak var BuyNowButton: UIButton!
    @IBOutlet weak var selectCurrency: UIView!
    @IBOutlet weak var selectCoinPairGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var menuButton: UIButton!
    
    var warningImageView: UIImageView!
    
    var cctransations = [cctransaction_global]
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    var m_spare_change_accrued_percent_to_invest : Double = 0.0
    var m_cap : Double = 0.0
    var m_percent_to_invest : Double = 0.0
    var m_how_often : Int = 0
    var m_spare_change_accrued : Double = 0.0
    var m_btc_to_invest : Double = 0.0
    var m_invest_on : Double = 0.0
    var m_btc_percentage: Double = 0.0
    var slider_progress_percentage: Double = 0.0 // Shows the slider progress towards right side
    
    var coinflashUser3ResponseObject: JSON!
    var cctransaction2ResponseObject: JSON!
    
    // MARK: - View Function
    
    override func viewDidLoad() {
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.default.menuDismissOnPush = true
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuParallaxStrength = 3
        NotificationCenter.default.addObserver(self, selector: #selector(didSuccessfullyBuyCoins(handleNotification:)), name: NSNotification.Name.onSuccessfulPurchaseOfCoins, object: nil)
        
        /// Get the bounds of settings icon and set the for warning over it if user has invalid months
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == false{
            self.warningImageView = UIImageView(image: UIImage(named: "warning"))
            self.view.addSubview(self.warningImageView)
        }
        
        if globalCoinflashUser3ResponseValue == nil{
            self.requestCoinflashUser5(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, showLoader: true)
        }
        // The following function will be called when the top one is completed
        //self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        //self.requestCoinflashUser3Values(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
        
        // side menu gesture		
        //SideMenuManager.default.menuAddPanGestureToPresent(toView: (self.navigationController?.view)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if SVProgressHUD.isVisible() || globalCCTransactionUserResponseValue == nil{
            HelperFunctions.LoadBankInfo()
            return
        }
        self.loadCCTRansactionFromGlobalVar()
        updateViewInvestmentInformation()
        self.requestCoinflashUser5(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, showLoader: false)
        // The following function will be called when the top one is completed
        //self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        //self.requestCoinflashUser3Values(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Show banners with respect to coinbase and plaid linkage info
        if !HelperFunctions.isCoinbaseLoggedIn() && !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: "Connect your coinbase account and bank to start investing.", style: .danger)
            banner.show()
            
            self.BuyNowButton.isEnabled = false
        }else if !HelperFunctions.isCoinbaseLoggedIn(){
            // let banner = NotificationBanner(title: "", subtitle: "Connect your coinbase account to start investing.", style: .danger)
            // banner.show()
            self.BuyNowButton.isEnabled = false
        }else if !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: " Connect your bank to start investing.", style: .danger)
            banner.show()
        }
    }
    
    override func viewWillLayoutSubviews() {
        // Show a prompt on settings button... if user hasnt subscribed to in app purchase
        if self.warningImageView != nil{
            self.warningImageView.layer.frame = CGRect(x: settingsPageButton.layer.frame.origin.x + settingsPageButton.frame.width - 8, y: settingsPageButton.layer.frame.origin.y, width: settingsPageButton.layer.frame.width/1.5, height: settingsPageButton.frame.height/1.5)
            if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == true{
                self.warningImageView.isHidden = true
            }else{
                self.warningImageView.isHidden = false
            }
        }
    }
    
    func updateViewInvestmentInformation(){
        self.LabelChangeTip?.text = String(Int(globalSettings.percentOfChangeToInvest)) + "% Of Your Change Will Be Invested Every Monday"
        self.LabelSinceChange?.text = "Spare Change Accrued Since Monday"
        // check to see the label
        
        if globalSettings.investHowOften == .monthly{
            // detect how far it is till next months 1st.
            let currentDate = Date()
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let days = cal.range(of: Calendar.Component.day, in: Calendar.Component.month, for: currentDate)
            let daysTillNextMonth = (days?.count)! - cal.component(Calendar.Component.day, from: currentDate)
            
            self.LabelChangeTip?.text = String(Int(globalSettings.percentOfChangeToInvest)) + "% Of Your Change Will Be Invested In \(daysTillNextMonth + 1) days"
            self.LabelSinceChange?.text = "Spare Change Accrued This Month"
        }
        
        self.LabelChange?.text = "$ " + String(self.m_spare_change_accrued_percent_to_invest)
        var bitrate = Double(0)
        
        //bitrate = m_btc_percentage
        bitrate = slider_progress_percentage
        let etherRate = 100 - bitrate
        
        self.LabelEtherInvestmentRate?.text = String(Int(etherRate)) + "%"
        self.LabelBitcoinInvestmentRate?.text = String(Int(bitrate)) + "%"
        
        // If investment is off
        if !globalSettings.investChange{
            self.LabelChangeTip?.text = "Investing Change Has Been Turned Off"
        }else{
            //print("Invest change is not off")
        }
    }
    
    // MARK: - Table View
    
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
    
    //MARK: - General Server Calls
    func requestCoinflashUser5(mobile_secret: String,user_id_mobile: String,mobile_access_token: String, showLoader: Bool ){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        
        if showLoader == true{
            SVProgressHUD.show(withStatus: "Loading Data")
        }
        
        Alamofire.request("https://coinflashapp.com/coinflashuser5/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success( _):
                SVProgressHUD.dismiss()
                self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: self.m_user_id, mobile_access_token: self.m_access_token, showLoader: showLoader)
                
                let json = JSON(response.result.value!)
                self.coinflashUser3ResponseObject = json[0]
                //print(json)
                globalCoinflashUser3ResponseValue = self.coinflashUser3ResponseObject
                print(globalCoinflashUser3ResponseValue["user_set_primary_coinbase_account_id"])
                
                if globalCoinflashUser3ResponseValue["how_paying"] != JSON.null{
                    //print(globalCoinflashUser3ResponseValue["how_paying"].string)
                    if globalCoinflashUser3ResponseValue["how_paying"].string == "1"{
                        StoreKitHelper.sharedInstance.monthlySubscriptionState = .managedOnWebsite
                    }
                    if globalCoinflashUser3ResponseValue["how_paying"].string == "0"{
                        StoreKitHelper.sharedInstance.monthlySubscriptionState = .notPurchased
                    }
                }
                
                if globalCoinflashUser3ResponseValue["in_app_purchase_receipt"] != JSON.null{
                    if globalCoinflashUser3ResponseValue["in_app_purchase_receipt"].string == ""{
                        if user_onboard_status == OnBoardStatus.linkedPlaidAndCoinbase{
                            // StoreKitHelper.sharedInstance.monthlySubscriptionState = .managedOnWebsite
                        }
                    }
                }
                
                // check if plaid needs relinking
                var plaidNeedsRelinking = false
                if globalCoinflashUser3ResponseValue["plaid_error_code"] != JSON.null{
                    if globalCoinflashUser3ResponseValue["plaid_error_code"].int == 2{
                        
                        plaidNeedsRelinking = true
                    }
                }
                
                // check if coinbase needs relinking
                var coinbaseNeedsRelinking = false
                if globalCoinflashUser3ResponseValue["wallets"].array?.count == 1{
                    let wallets = globalCoinflashUser3ResponseValue["wallets"].array!
                    if wallets[0].string != nil{
                        coinbaseNeedsRelinking = true
                    }
                }
                
                // SET THE SLIDER VALUE VIA BTC_PERCENTAGE
                if globalCoinflashUser3ResponseValue["btc_percentage"] != JSON.null{
                    let sliderProgress = Float(globalCoinflashUser3ResponseValue["btc_percentage"].string!)!;
                    let leftCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["left_side"].int!)
                    let rightCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["right_side"].int!)
                    if showLoader == true{
                        self.updateCryptoInvestmentSlider(value: sliderProgress, leftCurrency: leftCurrency, rightCurrency: rightCurrency)
                    }
                }
                
                if coinbaseNeedsRelinking == true && plaidNeedsRelinking == true{
                    
                    self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase and Bank account.  Please unlink and relink your bank and coinbase to resolve this issue.")
                }else if coinbaseNeedsRelinking == true{
                    self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase account.  Please unlink and relink your Coinbase account to resolve this issue.")
                }else if plaidNeedsRelinking == true{
                    self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Bank account.  Please unlink and relink your bank to resolve this issue.")
                }
                
            case .failure:
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "Error", message: "Network Error. Kindly check your connection and retry!", preferredStyle: UIAlertControllerStyle.alert)
                let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (action) in
                    self.viewWillAppear(false)
                })
                alert.addAction(retryAction)
                self.present(alert, animated: true, completion: nil)
                //self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: self.m_user_id, mobile_access_token: self.m_access_token)
                
                //print(response.error as Any)
            }
        }
    }
    
    func loadCCTRansactionFromGlobalVar(){
        
        let data = globalCCTransactionUserResponseValue.dictionaryObject
        
        let TransationArray = data!["cc_transactions_array"] as! [[String: Any]]
        let user_preferences = data!["user_preferences"] as! [String: Any]
        if user_preferences["spare_change_accrued_percent_to_invest"] != nil{
            self.m_spare_change_accrued_percent_to_invest = Double(user_preferences["spare_change_accrued_percent_to_invest"] as! String)!
            let sliderProgress = Float(globalCoinflashUser3ResponseValue["btc_percentage"].string!)!;
            let leftCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["left_side"].int!)
            let rightCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["right_side"].int!)
            self.updateCryptoInvestmentSlider(value: sliderProgress, leftCurrency: leftCurrency, rightCurrency: rightCurrency)
            //self.m_spare_change_accrued = Double(round(100 * self.m_spare_change_accrued_percent_to_invest)/100)
        }
        
        if user_preferences["spare_change_accrued"] != nil{
            self.m_spare_change_accrued = Double(user_preferences["spare_change_accrued"] as! String)!
        }
        if user_preferences["btc_to_invest"] != nil{
            self.m_btc_to_invest = user_preferences["btc_to_invest"] as! Double
            self.m_btc_to_invest = Double(round(100 * self.m_btc_to_invest)/100)
            
        }
        
        if user_preferences["btc_percentage"] != nil{
            //self.m_btc_percentage = user_preferences["btc_percentage"] as! Double
        }
        
        self.cctransations.removeAll()
        /// Bound error occuring check
        var TransationToAdd = true
        if TransationArray.count > 0{
            for index in 0...TransationArray.count - 1 {
                let transation = TransationArray[index]
                TransationToAdd = true
                var singleTransation = cctransaction_global
                if transation["cctransaction_name"] != nil{
                    singleTransation?.cctransaction_name = transation["cctransaction_name"] as! String
                }
                if transation["cctransaction_date"] != nil{
                    var date: String = transation["cctransaction_date"] as! String
                    let truncated = String(date.dropFirst(5))
                    singleTransation?.cctransaction_date = truncated
                }
                if transation["cctransaction_amount"] != nil{
                    singleTransation?.cctransaction_amount = transation["cctransaction_amount"] as! String!
                    let RowData = transation["cctransaction_amount"] as! String!
                    let cctransationCopy = Double(RowData!)
                    let difference = 1 - ( (cctransationCopy!) - (Double(Int(cctransationCopy!))))
                    
                    if difference <= 0 {
                        TransationToAdd = false
                        
                    }
                    else
                    {
                        let transation = self.roundtoPlace(num: difference, to: 2)
                        singleTransation?.cctransaction_amount  = "$ "+transation
                        
                    }
                    
                }
                if transation["coinbase_transaction_id"] != nil{
                    singleTransation?.cctransaction_coinbase_transaction_id = transation["coinbase_transaction_id"] as! String
                    singleTransation?.cctransaction_invested = "invested"
                }
                else{
                    singleTransation?.cctransaction_invested = "Not invested"
                }
                if TransationToAdd == true{
                    self.cctransations.append(singleTransation)
                }
            }
        }
        
        self.ccTransationTableView?.reloadData()
        self.updateViewInvestmentInformation()
    }
    
    func requestCoinFlashFeatchccTransations(mobile_secret: String,user_id_mobile: String,mobile_access_token: String, showLoader: Bool){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        
        if showLoader == true{
            SVProgressHUD.show(withStatus: "Loading Transactions")
        }
        
        Alamofire.request("https://coinflashapp.com/cctransactions2/", method: HTTPMethod.post, parameters: parameters,headers: headers)
            .responseJSON { response in
                switch response.result{
                case .success( _):
                    SVProgressHUD.dismiss()
                    
                        if response.result.value == nil {
                            HelperFunctions.showToast(withString: "Check Your Internet Connection", onViewController: self)
                        }
                        let data = response.result.value as! [String: Any]
                        //print(data)
                        if data["cc_transactions_array"] == nil
                        {
                            return
                        }
                    
                        let json = JSON(response.result.value)
                        globalCCTransactionUserResponseValue = json
                    
                        let TransationArray = data["cc_transactions_array"] as! [[String: Any]]
                        let user_preferences = data["user_preferences"] as! [String: Any]
                        if user_preferences["spare_change_accrued_percent_to_invest"] != nil{
                            self.m_spare_change_accrued_percent_to_invest = Double(user_preferences["spare_change_accrued_percent_to_invest"] as! String)!
                            let sliderProgress = Float(globalCoinflashUser3ResponseValue["btc_percentage"].string!)!;
                            let leftCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["left_side"].int!)
                            let rightCurrency = HelperFunctions.getCryptoCurrencyFromServerCode(code: globalCoinflashUser3ResponseValue["right_side"].int!)
                            if showLoader == true{
                                self.updateCryptoInvestmentSlider(value: sliderProgress, leftCurrency: leftCurrency, rightCurrency: rightCurrency)
                            }
                            //self.m_spare_change_accrued = Double(round(100 * self.m_spare_change_accrued_percent_to_invest)/100)
                        }
                        if user_preferences["percent_to_invest"] != nil{
                            self.m_percent_to_invest = Double(user_preferences["percent_to_invest"] as! String)!
                            globalSettings.percentOfChangeToInvest = Int(self.m_percent_to_invest)
                            
                        }
                        if user_preferences["cap"] != nil{
                            globalSettings.capOnInvestment = Int(user_preferences["cap"] as! String)
                        }
                        if user_preferences["how_often"] != nil{
                            self.m_how_often = Int(user_preferences["how_often"] as! String)!
                            if self.m_how_often == 1{
                                globalSettings.investHowOften = .daily
                            }
                            else if self.m_how_often == 2{
                                globalSettings.investHowOften = .weekly
                            }
                            else{
                                globalSettings.investHowOften = .monthly
                            }
                            
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
                            if self.m_invest_on == 1{
                                globalSettings.investChange = true
                            }else{
                                globalSettings.investChange = false
                            }
                        }
                        
                        if user_preferences["btc_percentage"] != nil{
                            //self.m_btc_percentage = user_preferences["btc_percentage"] as! Double
                        }
                        
                        self.cctransations.removeAll()
                        /// Bound error occuring check
                        var TransationToAdd = true
                        if TransationArray.count > 0{
                            for index in 0...TransationArray.count - 1 {
                                let transation = TransationArray[index]
                                TransationToAdd = true
                                var singleTransation = cctransaction_global
                                if transation["cctransaction_name"] != nil{
                                    singleTransation?.cctransaction_name = transation["cctransaction_name"] as! String
                                }
                                if transation["cctransaction_date"] != nil{
                                    var date: String = transation["cctransaction_date"] as! String
                                    let truncated = String(date.dropFirst(5))
                                    singleTransation?.cctransaction_date = truncated
                                }
                                if transation["cctransaction_amount"] != nil{
                                    singleTransation?.cctransaction_amount = transation["cctransaction_amount"] as! String!
                                    let RowData = transation["cctransaction_amount"] as! String!
                                    let cctransationCopy = Double(RowData!)
                                    let difference = 1 - ( (cctransationCopy!) - (Double(Int(cctransationCopy!))))
                                   
                                    if difference <= 0 {
                                        TransationToAdd = false
                                        
                                    }
                                    else
                                    {
                                        let transation = self.roundtoPlace(num: difference, to: 2)
                                        singleTransation?.cctransaction_amount  = "$ "+transation
                                        
                                    }
                                
                                }
                                if transation["coinbase_transaction_id"] != nil{
                                    singleTransation?.cctransaction_coinbase_transaction_id = transation["coinbase_transaction_id"] as! String
                                    singleTransation?.cctransaction_invested = "invested"
                                }
                                else{
                                    singleTransation?.cctransaction_invested = "Not invested"
                                }
                                if TransationToAdd == true{
                                    self.cctransations.append(singleTransation)
                                }
                            }
                        }
                        
                        self.ccTransationTableView?.reloadData()
                    if showLoader == true{
                        self.updateViewInvestmentInformation()
                    }
                        SVProgressHUD.dismiss()
                        
                case .failure:
                    //print(response.error as Any)
                    let alert = UIAlertController(title: "Error", message: "Network Error. Kindly check your connection and retry!", preferredStyle: UIAlertControllerStyle.alert)
                    let retryAction = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (action) in
                        self.viewWillAppear(false)
                    })
                    alert.addAction(retryAction)
                    self.present(alert, animated: true, completion: nil)
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    func sendSliderVaueToServerWithCurrency(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,SliderValue :Int,
                                            leftCurrencyCode: Int, rightCurrencyCode: Int){
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "slider_value" : "\(SliderValue)",
            "left_side" : "\(leftCurrencyCode)",
            "right_side" : "\(rightCurrencyCode)"
        ]
        
        SVProgressHUD.show(withStatus: "Updating Values")
        
        Alamofire.request("https://coinflashapp.com/coinflashuser5/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success( _):
                let data = response.result.value as? NSDictionary
                let SliderUpdated = data?.value(forKey: "success")
                //print(data)
                //let data = response.result.value as! [String: String]
                if SliderUpdated != nil
                {
                    // Update the global vars with respect to the change:
                    //self.m_btc_percentage = Double(SliderValue)
                }
                
                globalCoinflashUser3ResponseValue["right_side"].int = rightCurrencyCode
                globalCoinflashUser3ResponseValue["left_side"].int = leftCurrencyCode
                globalCoinflashUser3ResponseValue["btc_percentage"].string = String(100 - SliderValue)
                SVProgressHUD.dismiss()
            case .failure:
                //print(response.error as Any)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func showConfirmationDialogBox(title : String , Message : String)
    {
        let alert = UIAlertController(title: title, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Investment Label
    @IBOutlet weak var spareChangeAccuredToInvestLabel: UILabel!
    
    func updateDollarsToInvestInCryptoLabel(leftPercent: Int, rightPercent: Int, leftCurrency: CryptoCurrency, rightCurrency: CryptoCurrency){
        let dollarsToInvest = m_spare_change_accrued_percent_to_invest
        let leftCurrencyToInvest = dollarsToInvest * Double(leftPercent)/100
        let rightCurrencyToInvest = dollarsToInvest * Double(rightPercent)/100
        spareChangeAccuredToInvestLabel.text = String(format: "$ %.2f / $ %.2f", leftCurrencyToInvest, rightCurrencyToInvest)
    }
    
    //MARK: - Currency Selector
    var currencyPicker: UIPickerView!
    var pickerToolbar: UIToolbar!
    var currencyPickerIsAnimating: Bool!
    var currencyNamesForPickerView: [String] = ["Bitcoin","Ether","Litecoin","BitcoinCash"]
    @IBOutlet weak var currencySelctorLeftCurrencyIcon: UIImageView!
    @IBOutlet weak var currencySelctorLeftCurrencyLabel: UILabel!
    @IBOutlet weak var currencySelctorRightCurrencyIcon: UIImageView!
    @IBOutlet weak var currencySelctorRightCurrencyLabel: UILabel!

    
    @IBAction func didTapOnSelectCurrencyPairGesture(sender: UITapGestureRecognizer){
        if currencyPicker == nil{
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height/2.7
            let x = self.view.frame.origin.x
            let y = self.view.frame.origin.y + self.view.frame.height
            let frame = CGRect(x: x, y: y, width: width, height: height)
            currencyPicker = UIPickerView(frame: frame)
            currencyPicker.backgroundColor = UIColor.white
            self.view.addSubview(currencyPicker)
            currencyPicker.delegate = self
            currencyPicker.dataSource = self
            
            // Add the done button uitoolbar
            pickerToolbar = UIToolbar(frame: CGRect(x: x, y: y - 50, width: width, height: 50))
            self.view.addSubview(pickerToolbar)
            
            // Add the done button to pickertoolbar
            let pickerDoneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self
                , action: #selector(didPressPickerDoneButton(sender:)))
            let pickerToolBarFlexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
            pickerToolbar.setItems([pickerToolBarFlexibleSpace, pickerDoneButton], animated: false)
            
        }
        // Show the picker view to select currencies
        UIView.animate(withDuration: 0.5) {
            let width = self.view.frame.size.width
            let height = self.view.frame.size.height/2.8
            let x = self.view.frame.origin.x
            let y  = self.view.frame.origin.y + (self.view.frame.height - height)
            self.currencyPicker.frame = CGRect(x: x, y: y, width: width, height: height)
            
            self.pickerToolbar.frame = CGRect(x: x, y: y-50, width: width, height: 50)
        }
        
        // anime to picker to currently selected currency
        // -1 is done cause cryptoCurrency code start from 1 and picker array starts from 0
        currencyPicker.selectRow(HelperFunctions.getCodeFromCryptoCurrency(currency: (cryptoInvestmentSlider?.leftSideCurrency)!)-1, inComponent: 0, animated: true)
        currencyPicker.selectRow(HelperFunctions.getCodeFromCryptoCurrency(currency: (cryptoInvestmentSlider?.rightSideCurrency)!)-1, inComponent: 1, animated: true)
    }
    
    func didPressPickerDoneButton(sender: UIBarButtonItem){
        /// Check if picker has same item in both areas:
        if currencyPicker.selectedRow(inComponent: 0) == currencyPicker.selectedRow(inComponent: 1){
            // do a delay for such that the animation is completed
//            let timer = Timer(timeInterval: 1, repeats: false, block: { (timer) in
//                UIView.animate(withDuration: 0.5) {
//                    let width = self.view.frame.size.width
//                    let height = self.view.frame.size.height/2.8
//                    let x = self.view.frame.origin.x
//                    let y  = self.view.frame.origin.y + self.view.frame.height + 50
//                    self.currencyPicker.frame = CGRect(x: x, y: y, width: width, height: height)
//
//                    self.pickerToolbar.frame = CGRect(x: x, y: y-50, width: width, height: 50)
//                }
//                let firstCurrency = HelperFunctions.getCryptoCurrencyFromCode(code: self.currencyPicker.selectedRow(inComponent: 0)+1)
//                let secondCurrency = HelperFunctions.getCryptoCurrencyFromCode(code: self.currencyPicker.selectedRow(inComponent: 1)+1)
//                self.updateViewForNewlySlectedCurrency(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
//
//                self.sendSliderVaueToServerWithCurrency(mobile_secret: self.m_mobile_secret, user_id_mobile: self.m_user_id, mobile_access_token: self.m_access_token, SliderValue: (self.self.cryptoInvestmentSlider?.rightPercent)!, leftCurrencyCode: HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: firstCurrency), rightCurrencyCode: HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: secondCurrency))
//            })
            
        }else{
            print("Timer: %d && %d",currencyPicker.selectedRow(inComponent: 0), currencyPicker.selectedRow(inComponent: 1))
            UIView.animate(withDuration: 0.5) {
                let width = self.view.frame.size.width
                let height = self.view.frame.size.height/2.8
                let x = self.view.frame.origin.x
                let y  = self.view.frame.origin.y + self.view.frame.height + 50
                self.currencyPicker.frame = CGRect(x: x, y: y, width: width, height: height)
                
                self.pickerToolbar.frame = CGRect(x: x, y: y-50, width: width, height: 50)
            }
            let firstCurrency = HelperFunctions.getCryptoCurrencyFromCode(code: currencyPicker.selectedRow(inComponent: 0)+1)
            let secondCurrency = HelperFunctions.getCryptoCurrencyFromCode(code: currencyPicker.selectedRow(inComponent: 1)+1)
            self.updateViewForNewlySlectedCurrency(firstCurrency: firstCurrency, secondCurrency: secondCurrency)
            
            self.sendSliderVaueToServerWithCurrency(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, SliderValue: (cryptoInvestmentSlider?.rightPercent)!, leftCurrencyCode: HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: firstCurrency), rightCurrencyCode: HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: secondCurrency))
        }
    }
    
    /// Just updates the labels and icosn of the crypto currency selector view.
    func updateCryptoCurrencySelectorView(leftCurrency: CryptoCurrency, rightCurrency: CryptoCurrency){
        let firstCurrency = leftCurrency
        let secondCurrency = rightCurrency
        // Update the currency selector view to show the change in currency
        let leftCurrencyShortLabel = HelperFunctions.getShortNameForCryptoCurrency(currency: firstCurrency)
        let rightCurrencyShortLabel = HelperFunctions.getShortNameForCryptoCurrency(currency: secondCurrency)
        currencySelctorLeftCurrencyLabel.text = leftCurrencyShortLabel
        currencySelctorLeftCurrencyLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: firstCurrency)
        currencySelctorRightCurrencyLabel.text = rightCurrencyShortLabel
        currencySelctorRightCurrencyLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: secondCurrency)
        currencySelctorLeftCurrencyIcon.image = UIImage(named: HelperFunctions.getCurrencyIcon(currency: firstCurrency))
        currencySelctorRightCurrencyIcon.image = UIImage(named: HelperFunctions.getCurrencyIcon(currency: secondCurrency))
    }
    
    func updateViewForNewlySlectedCurrency(firstCurrency: CryptoCurrency, secondCurrency: CryptoCurrency){
        // Update the slider to reflect the correct colors
        self.cryptoInvestmentSliderChangeCurrency(leftCurrency: firstCurrency, rightCurrency: secondCurrency)
        
        // Update the currency selector view to show the change in currency
        let leftCurrencyShortLabel = HelperFunctions.getShortNameForCryptoCurrency(currency: firstCurrency)
        let rightCurrencyShortLabel = HelperFunctions.getShortNameForCryptoCurrency(currency: secondCurrency)
        currencySelctorLeftCurrencyLabel.text = leftCurrencyShortLabel
        currencySelctorLeftCurrencyLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: firstCurrency)
        currencySelctorRightCurrencyLabel.text = rightCurrencyShortLabel
        currencySelctorRightCurrencyLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: secondCurrency)
        currencySelctorLeftCurrencyIcon.image = UIImage(named: HelperFunctions.getCurrencyIcon(currency: firstCurrency))
        currencySelctorRightCurrencyIcon.image = UIImage(named: HelperFunctions.getCurrencyIcon(currency: secondCurrency))
    }
    
    //MARK: - Slider
    @IBOutlet weak var cryptoInvestmentSlider: CryptoPercentSliderControll?
    @IBOutlet weak var leftSideCryptoInvestmentPercentLabel: UILabel!
    @IBOutlet weak var leftSideCryptoInvestmentNameLabel: UILabel!
    @IBOutlet weak var rightsideCryptoInvestmentNameabel: UILabel!
    @IBOutlet weak var rightsideCryptoInvestmentPercentLabel: UILabel!
    
    func updateCryptoInvestmentSlider(value: Float){
        self.cryptoInvestmentSlider?.value = 100 - value
        cryptoInvestmentSlider?.leftPercent = Int(value)
        cryptoInvestmentSlider?.rightPercent = Int(100 - value)
        
        self.leftSideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.leftPercent)!)
        self.rightsideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.rightPercent)!)
        
        cryptoInvestmentSlider?.updateSliderColor()
        self.updateDollarsToInvestInCryptoLabel(leftPercent: cryptoInvestmentSlider!.leftPercent, rightPercent: cryptoInvestmentSlider!.rightPercent, leftCurrency: cryptoInvestmentSlider!.leftSideCurrency, rightCurrency: cryptoInvestmentSlider!.rightSideCurrency)
    }
    
    // call this to change the crypto sliders currency. CHanges the colors of and labels associated with the slider
    func cryptoInvestmentSliderChangeCurrency(leftCurrency: CryptoCurrency, rightCurrency: CryptoCurrency){
        cryptoInvestmentSlider?.leftSideCurrency = leftCurrency
        cryptoInvestmentSlider?.rightSideCurrency = rightCurrency
        
        self.leftSideCryptoInvestmentNameLabel.text = leftCurrency.rawValue
        self.rightsideCryptoInvestmentNameabel.text = rightCurrency.rawValue
        
        cryptoInvestmentSlider?.updateSliderColor()
        // also update the label colors
        leftSideCryptoInvestmentNameLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: leftCurrency)
        leftSideCryptoInvestmentPercentLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: leftCurrency)
        rightsideCryptoInvestmentNameabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: rightCurrency)
        rightsideCryptoInvestmentPercentLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: rightCurrency)
    }
    
    // called when user initializes the slider. Currency etc gets set here
    func updateCryptoInvestmentSlider(value: Float,  leftCurrency: CryptoCurrency, rightCurrency: CryptoCurrency){
        self.cryptoInvestmentSlider?.value = 100 - value
        cryptoInvestmentSlider?.leftSideCurrency = leftCurrency
        cryptoInvestmentSlider?.rightSideCurrency = rightCurrency
        
        self.leftSideCryptoInvestmentNameLabel.text = leftCurrency.rawValue
        self.rightsideCryptoInvestmentNameabel.text = rightCurrency.rawValue
        
        cryptoInvestmentSlider?.leftPercent = Int(value)
        cryptoInvestmentSlider?.rightPercent = Int(100 - value)
        
        self.leftSideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.leftPercent)!)
        self.rightsideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.rightPercent)!)
        
        cryptoInvestmentSlider?.updateSliderColor()
        // also update the label colors
        
        leftSideCryptoInvestmentNameLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: leftCurrency)
        leftSideCryptoInvestmentPercentLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: leftCurrency)
        rightsideCryptoInvestmentNameabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: rightCurrency)
        rightsideCryptoInvestmentPercentLabel.textColor = HelperFunctions.getColorForCryptoCurrency(currency: rightCurrency)
        
        self.updateDollarsToInvestInCryptoLabel(leftPercent: cryptoInvestmentSlider!.leftPercent, rightPercent: cryptoInvestmentSlider!.rightPercent, leftCurrency: leftCurrency, rightCurrency: rightCurrency)
        
        // Update the crypto currency selector view
        self.updateCryptoCurrencySelectorView(leftCurrency: leftCurrency, rightCurrency: rightCurrency)
    }
    
    @IBAction func didSlideCryptoInvestmentSlider(sender: CryptoPercentSliderControll){
        self.cryptoInvestmentSlider?.value = sender.value
        cryptoInvestmentSlider?.rightPercent = Int(ceil(sender.value))
        cryptoInvestmentSlider?.leftPercent = Int(100 - ceil(sender.value))
        self.leftSideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.leftPercent)!)
        self.rightsideCryptoInvestmentPercentLabel.text = String(format: "%d%%", (cryptoInvestmentSlider?.rightPercent)!)
        
        sender.updateSliderColor()
        self.updateDollarsToInvestInCryptoLabel(leftPercent: sender.leftPercent, rightPercent: sender.rightPercent, leftCurrency: sender.leftSideCurrency, rightCurrency: sender.rightSideCurrency)
    }
    
    @IBAction func onCryptoInvestmentSliderRelease(_ sender: Any) {
        var rate: Float = cryptoInvestmentSlider!.value
        rate = Float(Int(rate))
        _ =  rate
        
       // sendSliderVaueToServer(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token,
       //                        SliderValue: (cryptoInvestmentSlider?.rightPercent)!)
        let leftCurrencyCode = HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: (cryptoInvestmentSlider?.leftSideCurrency)!)
        let rightCurrencyCode = HelperFunctions.getCodeFromCryptoCurrencyForServerSide(currency: (cryptoInvestmentSlider?.rightSideCurrency)!)
        sendSliderVaueToServerWithCurrency(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, SliderValue: (cryptoInvestmentSlider?.rightPercent)!, leftCurrencyCode: leftCurrencyCode, rightCurrencyCode: rightCurrencyCode)
        //print("element Released")
    }
    
    func sendSliderVaueToServer(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,SliderValue :Int){
        
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
            case .success( _):
                let data = response.result.value as? NSDictionary
                let SliderUpdated = data?.value(forKey: "success")
                //let data = response.result.value as! [String: String]
                if SliderUpdated != nil
                {
                    // Update the global vars with respect to the change:
                    //self.m_btc_percentage = Double(SliderValue)
                }
                SVProgressHUD.dismiss()
            case .failure:
                //print(response.error as Any)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    //MARK: - Buy Now implementation
    @IBAction func didTapOnBuyNowButton(){
        /// Check if user has subscription:
        let testing = false
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == false && testing == false{
            let alert = UIAlertController(title: "", message: "Coinflash charges $1 a month for this feature, go to settings to set up your subscription.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            })
            let buyAction = UIAlertAction(title: "Buy Now", style: UIAlertActionStyle.default, handler: { (alertAction) in
                self.performSegue(withIdentifier: "mainViewToInAppPurchaseViewSegue", sender: self)
            })
            alert.addAction(action)
            alert.addAction(buyAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        /// checking if there is a coinbase account with allow_buy = true
        var allow_buy = false
        if coinflashUser3ResponseObject["coinbase_accounts"] != JSON.null{
            let accounts = coinflashUser3ResponseObject["coinbase_accounts"]
            for (_,subJson):(String, JSON) in accounts {
                if subJson["allow_buy"].bool == true{
                    allow_buy = true
                }
            }
        }else{
            
        }
        
        // if allow buy true then else show error
        //let testing = false
        if allow_buy == true || testing == true{
            //HelperFunctions.showToast(withString: "Buying is allowed", onViewController: self)
            let dollars = m_spare_change_accrued_percent_to_invest
            let dollarsToBuyBtc = (m_spare_change_accrued_percent_to_invest * Double((100 - (cryptoInvestmentSlider?.value)!)))/100
            let dollarsToBuyEther = (m_spare_change_accrued_percent_to_invest * Double((cryptoInvestmentSlider?.value)!))/100
            
            let firstCurrencyToBuyInDollars = m_spare_change_accrued_percent_to_invest * Double((cryptoInvestmentSlider?.leftPercent)!)/100
            let secondCurrencyToBuyInDollars = m_spare_change_accrued_percent_to_invest * Double((cryptoInvestmentSlider?.rightPercent)!)/100
            if (firstCurrencyToBuyInDollars < 3 && secondCurrencyToBuyInDollars < 3) && testing == false{
                HelperFunctions.showToast(withString: "Minimum amount required to buy any cryptocurrency is $3. Kindly review!", onViewController: self)
            }else{
                //self.requestServerToBuy(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, dollars: dollars)
                let popUpView: PopUpViewBuyNowSelector = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BuyPopUpView") as! PopUpViewBuyNowSelector
                // put the vars for showing the view
                popUpView.dollars = dollars
                popUpView.btcToBuyValueInDollars = dollarsToBuyBtc
                popUpView.etherToBuyValueInDollars = dollarsToBuyEther
                
                popUpView.firstCurrency = cryptoInvestmentSlider?.leftSideCurrency
                popUpView.secondCurrency = cryptoInvestmentSlider?.rightSideCurrency
                popUpView.firstCurrencyValueInDollars = firstCurrencyToBuyInDollars
                popUpView.secondCurrencyValueInDollars = secondCurrencyToBuyInDollars
                
                // Setting the transition settings
                popUpView.modalPresentationStyle = .overCurrentContext
                popUpView.modalTransitionStyle = .crossDissolve
                self.present(popUpView, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Payment Configuration Issue", message: "We found no Coinbase payment methods, you will not be able to buy cryptocurrency", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                //self.dismiss(animated: true, completion: nil)
            })
            let viewHelp = UIAlertAction(title: "View Help", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                UIApplication.shared.open(NSURL(string:"https://coinflashapp.com/support.html")! as URL, options: [:], completionHandler: nil)
            })
            
            alert.addAction(dismissAction)
            alert.addAction(viewHelp)
            //HelperFunctions.showToast(withString: "Configure your coinbase account in settings to buy items", onViewController: self)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Handles the buy notification which is called when the buy is successfull
    func didSuccessfullyBuyCoins(handleNotification notificaiton: NSNotification){
        let banner = NotificationBanner(title: "Success", subtitle: "You successfully bought cyrptocurrency using your spare change.", style: .success)
        banner.show()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier  == "generalSettingsSegue"{
            if globalCoinflashUser3ResponseValue == nil{
                self.requestCoinflashUser5(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, showLoader: true)
                HelperFunctions.showToast(withString: "Error! Loading Data", onViewController: self)
                return false
            }
        }
        return true
    }
    
    func roundtoPlace(num: Double, to places: Int) -> String {
        let p = log10(abs(num))
        let f = pow(10, p.rounded() - Double(places) + 1)
        _ = (num / f).rounded() * f
        let formate = "%." + String(places) + "f"
        let conversion = String(format:formate, num)
        _ = Double(conversion)
        return conversion
    }
    
    @IBAction func didPerformScreenEdgePanGesture(gesture: UIScreenEdgePanGestureRecognizer){
        self.menuButton.sendActions(for: .touchUpInside)
    }
}
