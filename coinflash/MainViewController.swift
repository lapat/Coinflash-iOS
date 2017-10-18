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
import LinkKit
import SwiftyJSON

//// Plaid
extension MainViewController : PLKPlaidLinkViewDelegate
{
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
            }
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: \(event)\nmetadata: \(metadata)")
    }
}

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
    var plaid_public_token = ""
    
    var m_spare_change_accrued_percent_to_invest : Double = 0.0
    var m_cap : Double = 0.0
    var m_percent_to_invest : Double = 0.0
    var m_how_often : Double = 0.0
    var m_spare_change_accrued : Double = 0.0
    var m_btc_to_invest : Double = 0.0
    var m_invest_on : Double = 0.0
    var m_btc_percentage: Double = 0.0
    
    
    @IBAction func InvestmentRateSlider(_ sender: UISlider) {
        let rate: Float = SliderinvestmentRateDecider!.value
        self.LabelBitcoinInvestmentRate?.text = String(format:"%.0f", rate) + "%"
        self.LabelEtherInvestmentRate?.text = String(format:"%.0f", (100 - rate)) + "%"
        
        let btcColor = UIColor(red: 8/255.0, green: 79/255.0, blue: 159/255.0, alpha: 1.0)
        let ethColor = UIColor(red: 110/255.0, green: 176/255.0, blue: 56/255.0, alpha: 1.0)
        let color = UIColor.blend(color1: btcColor, intensity1: (CGFloat(1.0 - rate/100.0)), color2: ethColor, intensity2: CGFloat(rate/100.0))
        print("Rate: \(rate) && btcIntensity : \(1.0 - rate/100.0) && intensity2: \(rate/100.0)")
        sender.thumbTintColor = color
        sender.minimumTrackTintColor = color
        sender.maximumTrackTintColor = color
        
        // Set the ether and bitcoin rate in the top label with respect to the percentage
        let dollarToInvestInBTC = Float(self.m_spare_change_accrued_percent_to_invest)*Float(rate/100.0)
        let dollarToInvestETH = Float(self.m_spare_change_accrued_percent_to_invest)*Float((100 - rate)/100.0)
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
        let Rate = SliderinvestmentRateDecider?.value
        UpdateSlideVaueToServer(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token,SliderValue: String(describing: Rate))
        //print("element Released")
        
    }
    
    @IBAction func TestPlaid(_ sender: Any) {
        if plaidInfoObject.loggedIn == true{
            let alert = UIAlertController(title: "Bank Account Link", message: "Already Logged In Do You want to deLink ?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: DelinkPlaid))
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        else{
            presentPlaidLinkWithSharedConfiguration()
        }
    }
    
    func DelinkPlaid(alert: UIAlertAction!) {
        
        DlinkPlaid(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
    }
    
    override func viewDidLoad() {
        SideMenuManager.default.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.default.menuDismissOnPush = true
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuParallaxStrength = 3
        self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
    }
    
    func updateViewInvestmentInformation(){
        self.LabelChangeTip?.text = String(Int(self.m_percent_to_invest)) + "% of Your Change Will Be Invested Every Monday"
        self.LabelChange?.text = "$ " + String(self.m_spare_change_accrued_percent_to_invest)
        var bitrate = Double(0)
        //var RationBitCoint =
       
        bitrate = m_btc_percentage
        let etherRate = 100 - bitrate
        
        self.LabelEtherInvestmentRate?.text = String(Int(etherRate)) + "%"
        self.LabelBitcoinInvestmentRate?.text = String(Int(bitrate)) + "%"
        print()
        print(bitrate)
        self.SliderinvestmentRateDecider?.value = Float(bitrate)
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
            let data = response.result.value as! [String: Any]
             if data["cc_transactions_array"] == nil
             {
                SVProgressHUD.dismiss()
                return
             }
            print(response)
             let TransationArray = data["cc_transactions_array"] as! [[String: Any]]
             let user_preferences = data["user_preferences"] as! [String: Any]
             if user_preferences["spare_change_accrued_percent_to_invest"] != nil{
                self.m_spare_change_accrued_percent_to_invest = Double(user_preferences["spare_change_accrued_percent_to_invest"] as! String)!
                self.m_spare_change_accrued = Double(round(100 * self.m_spare_change_accrued_percent_to_invest)/100)
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
        
        }
       

    }
    
    
    func LinkPlaid(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,public_token :String){
      
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "public_token" : public_token
            
            ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            
            let data = response.result.value as? NSDictionary
                
            let PLD = data?.value(forKey: "plaid_authorization_success")
            let AA = data?.value(forKey: "already_authorized")
            
            //let data = response.result.value as! [String: String]
            if PLD != nil
            {
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Linked")
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
                
            }
            else if AA != nil{
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Already Linked")
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
            }
            else
            {
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Link Fail : Retry")
                
            }
            // Loading the data in the Table
            
            
            
        }
    }
    func DlinkPlaid(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "unlink_credit_card" : "true"
            
        ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            
            let data = response.result.value as? NSDictionary
            
            let DR = data?.value(forKey: "disconnect_returned")
            if DR != nil
            {
                
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Dlinked")
                HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                
                
            
            }
            else
            {
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "DeLinking Fail : Retry")
                
            }
            
            SVProgressHUD.dismiss()
        }
    }
    
    func showConfirmationDialogBox(title : String , Message : String)
    {
        
        let alert = UIAlertController(title: title, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    func UpdateSlideVaueToServer(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,SliderValue :String){
        
        let headers: HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
        "mobile_secret" : mobile_secret,
        "user_id_mobile" : user_id_mobile,
        "mobile_access_token" : mobile_access_token,
        "slider_value" : SliderValue
        
        ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/coinflashuser3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
        
            let data = response.result.value as? NSDictionary
            let SliderUpdated = data?.value(forKey: "success")
            print(response)
            //let data = response.result.value as! [String: String]
            if SliderUpdated != nil
            {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
        
    
    ///////////////////////////////////// PLAID //////////////////////////////////////
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        self.plaid_public_token = publicToken
        LinkPlaid(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, public_token: publicToken)
        
      //  presentAlertViewWithTitle("Success", message: "token: \(publicToken)\nmetadata: \(metadata ?? [:])")
        
    }
    
    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }
    
    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Plaid Link setup with shared configuration from Info.plist
    func presentPlaidLinkWithSharedConfiguration() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate as! PLKPlaidLinkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    }
    
    // MARK: Plaid Link setup with custom configuration
    func presentPlaidLinkWithCustomConfiguration() {
        let linkConfiguration = PLKConfiguration(key: "93bf429075d0e7ff0fc28750127c45", env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate as! PLKPlaidLinkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    
    }
    
}

