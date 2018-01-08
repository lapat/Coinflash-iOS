//
//  AccountSettingVC.swift
//  coinflash
//
//  Created by tallal on 9/30/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import coinbase_official
import SVProgressHUD
import Alamofire
import SwiftyJSON
import LinkKit
import NotificationBannerSwift

class PlaidBankCell: UITableViewCell{
    @IBOutlet weak var bankPicImageView: UIImageView!
    @IBOutlet weak var bankNameLabel: UILabel!
    @IBOutlet weak var bankAccountNumber: UILabel!
}

//// Plaid
extension AccountSettingsVC : PLKPlaidLinkViewDelegate
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

class AccountSettingsVC: UIViewController, UITableViewDataSource{
    @IBOutlet weak var bankTable: UITableView!
    @IBOutlet weak var coinbaseLinkedLabel: UILabel!
    @IBOutlet weak var addCoinbaseButton: UIButton!
    @IBOutlet weak var plaidLinkedImageView: UIImageView!
    @IBOutlet weak var coinbaseLinkedImageView: UIImageView!
    @IBOutlet weak var overallLinkedImageView: UIImageView!
    
    @IBOutlet weak var AddBankLink: UIButton!
    @IBOutlet weak var DlinkAccounts: UILabel!
    var plaidAccounts: [JSON]!
    
    
    @IBOutlet weak var createCoinbaseAccount: UIButton!
    @IBOutlet weak var createCoinbaseAccountLabel: UILabel!
    
    @IBOutlet weak var DlinkCoinBase: UIButton!
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    var plaid_public_token : String = ""
    override func viewDidLoad() {
        
        let nc =  NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewDidEnterForground(notificaiton:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        // register for notifaction of coinbase api login being completed
        nc.addObserver(self, selector: #selector(coinBaseAuthenticationCompleted(withNotification:)), name: NSNotification.Name.onCoinbaseLoginCompletion, object: nil)
        nc.addObserver(self, selector: #selector(coinBaseAuthenticationStarting(withNotification:)), name: NSNotification.Name.onCoinbaseLoginStart, object: nil)
        
        self.getCoinFlashUserInfo()
        if !HelperFunctions.isCoinbaseLoggedIn() && !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: "Connect your coinbase account and bank to start investing.", style: .danger)
            //banner.show()
        }else if !HelperFunctions.isCoinbaseLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: "Connect your coinbase account to start investing.", style: .danger)
            //banner.show()
        }else if !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: " Connect your bank to start investing.", style: .danger)
            //banner.show()
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "DlinkBothAccounts:")
        DlinkAccounts.addGestureRecognizer(gestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AccountSettingsVC.DlinkBothAccounts))
        DlinkAccounts.isUserInteractionEnabled = true
        DlinkAccounts.addGestureRecognizer(tap)
        
        //self.loadInAppPurchaseView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func updateViews(){
        // Check for coing base linkage
       /*
        if HelperFunctions.isCoinbaseLoggedIn() == true{
            coinbaseLinkedLabel.text = "Coinbase Linked"
            self.addCoinbaseButton.isHidden = true
            //self.DlinkCoinBase.isHidden = false
            self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseGreen")
        }else{
            coinbaseLinkedLabel.text = "Coinbase Not Linked"
            self.addCoinbaseButton.isHidden = false
            //self.DlinkCoinBase.isHidden = true
            self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseTopGray")
        }
        
        // Check for plaid linkage
        if HelperFunctions.isPlaidLoggedIn() == true{
            self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGreenicon")
            
        }else{
            self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGray")
        }
        */
        if HelperFunctions.isPlaidLoggedIn() && HelperFunctions.isCoinbaseLoggedIn() {
            self.overallLinkedImageView.image = UIImage(imageLiteralResourceName: "linkedIcon")
        }else{
            self.overallLinkedImageView.image = UIImage(imageLiteralResourceName: "notLinked")
        }
       
        if  HelperFunctions.isCoinbaseLoggedIn() == true{
           coinbaseLinkedLabel.text = "Coinbase Linked"
           self.addCoinbaseButton.isHidden = true
           self.DlinkAccounts.isHidden = false
           self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseGreen")
            self.createCoinbaseAccount.isHidden = true
            self.createCoinbaseAccountLabel.isHidden = true
            
           if HelperFunctions.isPlaidLoggedIn() == true{
             self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGreenicon")
             self.AddBankLink.isHidden = true
            
           }
           else
           {
            self.AddBankLink.isHidden = false
            self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGray")
            
            }
        }
        else
        {   coinbaseLinkedLabel.text = "Coinbase Not Linked"
            self.addCoinbaseButton.isHidden = false
            self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseTopGray")
            self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGray")
            self.AddBankLink.isHidden = true
            self.DlinkAccounts.isHidden = true
            self.createCoinbaseAccount.isHidden = false
            self.createCoinbaseAccountLabel.isHidden = false
            
            
        }
    }
    
    @IBAction func DlinkCoinbaseAction(_ sender: Any) {
        
        self.DlinkCoinbase(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
    }
    
    @IBAction func didtaponCreatAccount(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.coinbase.com/join/5924d7298fb60a02816ccc08") as! URL)
        dismiss(animated: true, completion: nil)
    }
    func viewDidEnterForground(notificaiton: NSNotification){
        if (UIApplication.shared.delegate as! AppDelegate).processingBacklink == true{
            //SVProgressHUD.show(withStatus: "Processing Login")
            //UIApplication.shared.beginIgnoringInteractionEvents()
            
        }else{
            if HelperFunctions.isPlaidLoggedIn() == true{
                //coinbaseLinkedLabel.text = "Coinbase Linked"
                //self.DlinkCoinBase.isHidden = true
                //self.requestCoinbaseLinkAPIRequest()
            }else{
                //coinbaseLinkedLabel.text = "Coinbase Not Linked"
                //self.DlinkCoinBase.isHidden = false
                //self.addCoinbaseButton.isHidden = false
            }
        }
    }
    
    func coinBaseAuthenticationCompleted(withNotification notificaion: NSNotification){
        SVProgressHUD.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
        if HelperFunctions.isCoinbaseLoggedIn() == true{
            //self.coinbaseLinkedLabel.text = "Coinbase Linked"
            //self.DlinkCoinBase.isHidden = false
            //self.addCoinbaseButton.isHidden = true
            self.requestCoinbaseLinkAPIRequest()
        }else{
            self.coinbaseLinkedLabel.text = "Coinbase Not Linked"
            self.addCoinbaseButton.isHidden = false
            //self.DlinkCoinBase.isHidden = true
        }
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = false
    }
    
    func coinBaseAuthenticationStarting(withNotification notification: NSNotification){
        SVProgressHUD.show()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.row == 0 && plaidAccounts == nil || plaidAccounts.count < 1{
            cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell")
            plaidInfoObject.loggedIn = false
            //self.AddBankLink.isHidden = false
            //self.AddBankLink.setImage( UIImage.init(named: "addNwbanks"), for: .normal)
            //self.DlinkAccounts.isHidden = false
            //self.AddBankLink.image.image = UIImage(named:"addNwbanks")!
            
        }else{
            let plaidCell = tableView.dequeueReusableCell(withIdentifier: "normalCell") as! PlaidBankCell
            plaidCell.bankNameLabel.text = plaidAccounts[indexPath.row]["plaid_account_name"].string
            plaidCell.bankAccountNumber.text = ("**** **** ****\(plaidAccounts[indexPath.row]["last_four_digits"].string!)")
            cell = plaidCell
            plaidInfoObject.loggedIn = true
            HelperFunctions.managePlaidLinked()
            //self.AddBankLink.isHidden = true
            //self.AddBankLink.setImage( UIImage.init(named: "unlinkBank"), for: .normal)
           
            
            //self.AddBankLink.image = UIImage(named:"unlinkBank")!
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if plaidAccounts == nil || plaidAccounts.count < 1{
            return 1
        }else{
            return plaidAccounts.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func didTapOnAddCoinbaseButton(sender: UIButton){
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = true
        CoinbaseOAuth.startAuthentication(withClientId: "723e663bdd30aac0f9641160de28ce520e1a065853febbd9a9c983569753bcf3", scope: "wallet:user:read,wallet:buys:create,wallet:payment-methods:read,wallet:accounts:read,wallet:transactions:send,wallet:addresses:read,wallet:transactions:send:bypass-2fa", redirectUri: "com.coinbasepermittedcoinflash.apps.coinflash-12345678://coinbase-oauth", meta: ["send_limit_amount": "5.00", " send_limit_currency": "USD", "send_limit_period": "week"])
    }
    
    //MARK: - PickerView For Coinflash Account
    func didTapOnCoinbaseCreditCard(sender: Any){
        
    }
    
    // MARK: - API
    func requestCoinbaseLinkAPIRequest(){
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "code": coinbaseInfoObject.accessToken, "redirect_url": "com.coinbasepermittedcoinflash.apps.coinflash-12345678://coinbase-oauth", "coinbase_refresh_access_token": coinbaseInfoObject.refreshToken]
        SVProgressHUD.show(withStatus: "Linking Coinbase")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)auththirdparty3/", method: HTTPMethod.post, parameters: parameter)
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    let data = response.result.value as! [String: Any]
                   // print(response)
                    // Dismiss all views and load the login view
                    
                    SVProgressHUD.dismiss()
                    self.coinbaseLinkedLabel.text = "Coinbase Linked"
                    //self.DlinkCoinBase.isHidden = false
                    self.addCoinbaseButton.isHidden = true
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.addCoinbaseButton.isHidden = true
                    self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseGreen")
                    HelperFunctions.manageCoinBaseLinking()
                    self.updateViews()
                case .failure:
                 //   print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.addCoinbaseButton.isHidden = false
                    self.updateViews()
                }
        }
    }
    
    func getCoinFlashUserInfo(){
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token]
        SVProgressHUD.show(withStatus: "Loading Account info")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)coinflashuser3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                  //  print(value)
                    let accounts = json[0]["plaid_accounts"].array
                    self.plaidAccounts = accounts
                    
                    self.bankTable.reloadData()
                    // dismiss the progress hud
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.updateViews()
                case .failure:
               //     print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
    }
    
    @IBAction func AddAccount(_ sender: Any) {
        if plaidInfoObject.loggedIn == true{
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to unlink your bank?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: DelinkPlaid))
            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
            
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
    // Plaid .......
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        self.plaid_public_token = publicToken
        LinkPlaid(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, public_token: publicToken)
        
        
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
        let linkConfiguration = PLKConfiguration(key: "93bf429075d0e7ff0fc28750127c45", env: .production, product: .transactions)
        linkConfiguration.clientName = ""
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate as! PLKPlaidLinkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
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
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON
            { response in
            
            let data = response.result.value as? NSDictionary
            
            let PLD = data?.value(forKey: "plaid_authorization_success")
            let AA = data?.value(forKey: "already_authorized")
            
            //let data = response.result.value as! [String: String]
            if PLD != nil
            {
                
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Linked")
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
                self.getCoinFlashUserInfo()
                    self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGreenicon")
                HelperFunctions.managePlaidLinked()
                self.updateViews()
                
                /// Check if plaid and coinbase are linked and use is not registered for subscriptions.. Then show in app purchases view
                if user_onboard_status == OnBoardStatus.linkedPlaidAndCoinbase{
                    if globalCoinflashUser3ResponseValue["has_payment"].string == "0"{
                        self.loadInAppPurchaseView()
                    }
                }
            }
            else if AA != nil{
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Already Linked")
                HelperFunctions.managePlaidLinked()
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
            }
            else
            {
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Link Fail : Retry")
                
            }
            self.updateViews()
            // Loading the data in the Table
            
        }
    }
    
    func loadInAppPurchaseView(){
        let storyboard = self.storyboard
        let inAppView = storyboard?.instantiateViewController(withIdentifier: "in-app-purchase-view")
        self.navigationController?.pushViewController(inAppView!, animated: true)
    }
    
    func DlinkCoinbase(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "revoke_coinbase_token" : "true"]
        
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                let data = response.result.value as? NSDictionary
              //  print(response)
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Coinbase", message: " Your Coinbase account was unlinked.")
                    
                self.coinbaseLinkedLabel.text = "Coinbase Not Linked"
                self.addCoinbaseButton.isHidden = false
                
                
                HelperFunctions.manageCoinbaseDelinking()
                self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseTopGray")
                self.updateViews()
                
            case .failure:
            //    print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.presentAlertViewWithTitle("CoinBase", message: "DeLinking Fail : Retry")
                self.presentAlertViewWithTitle("Coinbase", message: " Your Coinbase account dLink Failed: Please Retry ")
                
            }
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
            "unlink_credit_card" : "true"]
        
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                let data = response.result.value as? NSDictionary
                
                let DR = data?.value(forKey: "disconnect_returned")
                if DR != nil
                {
                    
                    SVProgressHUD.dismiss()
                    self.presentAlertViewWithTitle("Success", message: "Your bank account was unlinked..")
                    HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                    self.AddBankLink.setImage( UIImage.init(named: "addNwbanks"), for: .normal)
                    plaidInfoObject.loggedIn = false
                    self.plaidAccounts = []
                    self.bankTable.reloadData()
                    self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGray")
                    HelperFunctions.managePlaidDelinking()
                    self.updateViews()
                    
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.presentAlertViewWithTitle("Bank Account Link", message: "DeLinking Fail : Retry")
                    
                }
                
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Success", message: "Bank Accounts Delinked")
                HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                self.updateViews()
                
            case .failure:
             //   print(response.error as Any)
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Failure", message: "De Linking Failed : Retry")
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    /////////////////////////////////// Dlink Plaid and Coinbase ///////////////////////////////////
    
    func DlinkCoinbaseCombine(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "revoke_coinbase_token" : "true"]
        
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success(let value):
                let data = response.result.value as? NSDictionary
             //   print(response)
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Coinbase", message: " Your Coinbase account was unlinked.")
                
                self.coinbaseLinkedLabel.text = "Coinbase Not Linked"
                self.addCoinbaseButton.isHidden = false
                
                
                HelperFunctions.manageCoinbaseDelinking()
                self.coinbaseLinkedImageView.image = UIImage(imageLiteralResourceName: "coinbaseTopGray")
                self.updateViews()
                
            case .failure:
             //   print(response.error as Any)
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.presentAlertViewWithTitle("CoinBase", message: "DeLinking Fail")
                self.presentAlertViewWithTitle("Coinbase", message: " Your Coinbase account dLink Failed: Please Retry ")
                
            }
        }
    }
    
    func DlinkPlaidCombine(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "unlink_credit_card" : "true"]
        
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success:
                let data = response.result.value as? NSDictionary
                
                let DR = data?.value(forKey: "disconnect_returned")
                if DR != nil
                {
                    
                    SVProgressHUD.dismiss()
                    self.presentAlertViewWithTitle("Success", message: "Your bank account was unlinked..")
                    HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                    self.AddBankLink.setImage( UIImage.init(named: "addNwbanks"), for: .normal)
                    plaidInfoObject.loggedIn = false
                    self.plaidAccounts = []
                    self.bankTable.reloadData()
                    self.plaidLinkedImageView.image = UIImage(imageLiteralResourceName: "bankGray")
                    HelperFunctions.managePlaidDelinking()
                    self.updateViews()
                    
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.presentAlertViewWithTitle("Bank Account Link", message: "DeLinking Fail : Retry")
                    
                }
                
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Success", message: "Bank Accounts Delinked")
                HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                self.updateViews()
                
            case .failure:
            //    print(response.error as Any)
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Failure", message: "DeLinking Failed")
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
    }
    
    func DlinkBothAccounts(sender:UITapGestureRecognizer)  {
        if HelperFunctions.isPlaidLoggedIn() == true || HelperFunctions.isCoinbaseLoggedIn() == true {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to unlink your accounts?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: DlinkBanksAndCoinbase))
            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func DlinkBanksAndCoinbase(alert: UIAlertAction!) {
        if HelperFunctions.isPlaidLoggedIn() == true{
            
         DlinkPlaidCombine(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        }
        if HelperFunctions.isCoinbaseLoggedIn() == true{
            DlinkCoinbaseCombine(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        }
    }
    
}
