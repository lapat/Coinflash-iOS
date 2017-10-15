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
    var m_mobile_secret = "8dkkaiei20kdjkwoeo29ddkskalw82asD!"
    var m_user_id = "425"
    var m_access_token = "cc5ee533482541e7b38d5aa96844df"
    var plaid_public_token = ""
    
    @IBAction func InvestmentRateSlider(_ sender: Any) {
        let Rate = SliderinvestmentRateDecider?.value
        self.LabelBitcoinInvestmentRate?.text = String(format:"%.0f", Rate!) + "$"
        self.LabelEtherInvestmentRate?.text = String(format:"%.0f", (100 - Rate!)) + "$"
        
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

    @IBAction func TestPlidAction(_ sender: Any) {
        //presentPlaidLinkWithSharedConfiguration()

    }
    
    override func viewDidLoad() {
        SideMenuManager.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.menuDismissOnPush = true
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuParallaxStrength = 3
        //self.requestCoinFlashFeatchccTransations(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        HelperFunctions.LoadBankInfo()
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
        
       Alamofire.request("https://coinflashapp.com/cctransactions2/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
             let data = response.result.value as! [String: Any]
             if data["cc_transactions_array"] == nil
             {
                SVProgressHUD.dismiss()
                return
             }
             let TransationArray = data["cc_transactions_array"] as! [[String: Any]]
        
             self.cctransations.removeAll()
        /// Bound error occuring check
        
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
            self.ccTransationTableView?.reloadData()
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
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "true")
                
            }
            else if AA != nil{
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Linked")
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "true")
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
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
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
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    
    }
    
}



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

