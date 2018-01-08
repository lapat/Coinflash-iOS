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
    @IBOutlet weak var settingsPageButton: UIButton!
    var warningImageView: UIImageView!
    
   
    @IBOutlet weak var BuyNowButton: UIButton!
    
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
    
    var coinflashUser3ResponseObject: JSON!
    var cctransaction2ResponseObject: JSON!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        self.requestCoinflashUser3Values(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
        if self.warningImageView != nil{
            self.warningImageView.layer.frame = CGRect(x: settingsPageButton.layer.frame.origin.x + settingsPageButton.frame.width - 8, y: settingsPageButton.layer.frame.origin.y, width: settingsPageButton.layer.frame.width/1.5, height: settingsPageButton.frame.height/1.5)
            if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == true{
                self.warningImageView.isHidden = true
            }else{
                self.warningImageView.isHidden = false
            }
        }
    }
    
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
        if globalSettings.investChange == false{
            self.LabelChange?.text = String(format: "$ %.2f / %.2f", 0.0,0.0)
            return
        }
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
        let btcRate = rate
        
        UpdateSlideVaueToServer(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token,SliderValue: Int(btcRate))
        //print("element Released")
    }
    
    func updateViewInvestmentInformation(){
        self.LabelChangeTip?.text = String(Int(self.m_percent_to_invest)) + "% Of Your Change Will Be Invested Every Monday"
         self.LabelSinceChange?.text = "Spare Change Accrued Since Monday"
        // check to see the label
        
        if globalSettings.investHowOften == .monthly{
            // detect how far it is till next months 1st.
            let currentDate = Date()
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let days = cal.range(of: Calendar.Component.day, in: Calendar.Component.month, for: currentDate)
            let daysTillNextMonth = (days?.count)! - cal.component(Calendar.Component.day, from: currentDate)
            
            self.LabelChangeTip?.text = String(Int(self.m_percent_to_invest)) + "% Of Your Change Will Be Invested In \(daysTillNextMonth + 1) days"
           self.LabelSinceChange?.text = "Spare Change Accrued This Month"
        }
        
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
                        //print(data)
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
                        }
                        
                        if user_preferences["btc_percentage"] != nil{
                            self.m_btc_percentage = user_preferences["btc_percentage"] as! Double
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
                                    let truncated = String(date.characters.dropFirst(5))
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
                        SVProgressHUD.dismiss()
                        
                    }catch {
                        
                        SVProgressHUD.dismiss()
                    }
                case .failure:
                    //print(response.error as Any)
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
                //print(response.error as Any)
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
        
        Alamofire.request("https://coinflashapp.com/coinflashuser4/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                let json = JSON(response.result.value)
                self.coinflashUser3ResponseObject = json[0]
                //print(json)
                globalCoinflashUser3ResponseValue = self.coinflashUser3ResponseObject
                SVProgressHUD.dismiss()
                
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
                
                if coinbaseNeedsRelinking == true && plaidNeedsRelinking == true{
                    
                        self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase and Bank account.  Please unlink and relink your bank and coinbase to resolve this issue.")
                }else if coinbaseNeedsRelinking == true{
                    self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase account.  Please unlink and relink your Coinbase account to resolve this issue.")
                }else if plaidNeedsRelinking == true{
                    self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Bank account.  Please unlink and relink your bank to resolve this issue.")
                }
            
            case .failure:
                //print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    //MARK: - Buy Now implementation
    @IBAction func didTapOnBuyNowButton(){
        /// Check if user has subscription:
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == false{
            let alert = UIAlertController(title: "", message: "Coinflash charges $1 a month for this feature, go to settings to set up your subscription.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                
            })
            alert.addAction(action)
            //self.present(alert, animated: true, completion: nil)
            //return
        }
        
        
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
        let testing = true
        if allow_buy == true || testing == true{
            //HelperFunctions.showToast(withString: "Buying is allowed", onViewController: self)
            let dollars = m_spare_change_accrued_percent_to_invest
            let dollarsToBuyBtc = (m_spare_change_accrued_percent_to_invest * Double((100 - (SliderinvestmentRateDecider?.value)!)))/100
            let dollarsToBuyEther = (m_spare_change_accrued_percent_to_invest * Double((SliderinvestmentRateDecider?.value)!))/100
            if dollarsToBuyEther < 3 && dollarsToBuyBtc < 3{
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
            let alert = UIAlertController(title: "Payment Configuration Issue", message: "We found no Coinbase payment methods, you will not be able to buy cryptocurrency", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                //self.dismiss(animated: true, completion: nil)
            })
            let viewHelp = UIAlertAction(title: "View Help", style: UIAlertActionStyle.default, handler: { (alert: UIAlertAction) in
                UIApplication.shared.open(NSURL(string:"https://coinflashapp.com/support.html") as! URL, options: [:], completionHandler: nil)
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
                self.requestCoinflashUser3Values(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
                HelperFunctions.showToast(withString: "Error! Trying to reload Data", onViewController: self)
                return false
            }
        }
        return true
    }
    func roundtoPlace(num: Double, to places: Int) -> String {
        let p = log10(abs(num))
        let f = pow(10, p.rounded() - Double(places) + 1)
        let rnum = (num / f).rounded() * f
        let formate = "%." + String(places) + "f"
        let conversion = String(format:formate, num)
        let output = Double(conversion)
        return conversion
    }
}

