//
//  SettingsViewController.swift
//  CoinFlash
//
//  Created by robert pham on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON
import LinkKit
import NotificationBannerSwift
import FBSDKLoginKit

class SettingsViewController: UIViewController, MainNewStoryboardInstance {

    @IBOutlet weak var tableView: UITableView!
    
    var plaidAccounts = [JSON]()
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    var plaid_public_token : String = ""
    
    var actionCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 90
        tableView.register(CardSettingCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        let nc =  NotificationCenter.default
        // register for notifaction of coinbase api login being completed
        nc.addObserver(self, selector: #selector(coinBaseAuthenticationCompleted(withNotification:)), name: NSNotification.Name.onCoinbaseLoginCompletion, object: nil)
        self.getCoinFlashUserInfo()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func unlinkButtonPressed(_ sender: Any) {
        if HelperFunctions.isPlaidLoggedIn() == true || HelperFunctions.isCoinbaseLoggedIn() == true {
            let alert = UIAlertController(title: "Warning", message: "Are you sure you want to unlink your accounts?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: DlinkBanksAndCoinbase))
            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func helpSupportButtonPressed(_ sender: Any) {
        let url = URL(string: "https://coinflashapp.com/support/")!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        let alertVc = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.logoutNow()
        }
        alertVc.addAction(cancelAction)
        alertVc.addAction(okAction)
        present(alertVc, animated: true, completion: nil)
    }
    
    
    fileprivate func logoutNow() {
        let mobileSecret = String(describing: user_mobile_secret!)

        let parameter: Parameters = ["mobile_secret": mobileSecret, "user_id_mobile": String(describing:user_id_mobile!), "mobile_access_token": String(describing:user_mobile_access_token!)]
        SVProgressHUD.show()
        Alamofire.request("\(baseUrl)signout2/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    let data = response.result.value as! [String: Any]
                    print(data)
                    // Dismiss all views and load the login view
                    user_isLoggedIn = false
                    
                    HelperFunctions.updateVariablesForUserLoggingOut()
                    
                    SVProgressHUD.dismiss()
                    
                    guard let app = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    app.goToLoginPage()
                    GIDSignIn.sharedInstance().signOut()
                    FBSDKLoginManager().logOut()
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                }
        }
    }

    // MARK: Coinbase
    fileprivate func linkCoinbase() {
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = true
        CoinbaseOAuth.startAuthentication(withClientId: "fb8d49906184ea0934d6d60c05b2f336f94f93b30bf9708a1a77d0f7c7e10fc5", scope: "wallet:user:email,wallet:user:read,wallet:buys:create,wallet:buys:read,wallet:payment-methods:read,wallet:accounts:read,wallet:addresses:read,wallet:transactions:send,wallet:addresses:create", redirectUri: "com.coinbasepermittedcoinflash1.apps.coinflash-999://coinbase-oauth", meta: ["send_limit_amount": "1.00", " send_limit_currency": "USD", "send_limit_period": "week"])
    }
    func coinBaseAuthenticationCompleted(withNotification notificaion: NSNotification){
        SVProgressHUD.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
        if HelperFunctions.isCoinbaseLoggedIn() == true{
            self.requestCoinbaseLinkAPIRequest()
        } else{
            
        }
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = false
    }
    
    func requestCoinbaseLinkAPIRequest(){
        print("user_id_mobile")
        print(user_id_mobile)
        print("user_mobile_secret")
        print(user_mobile_secret)
        print("coinbaseInfoObject.accessToken")
        print(coinbaseInfoObject.accessToken)
        print("coinbaseInfoObject.refreshToken")
        print(coinbaseInfoObject.refreshToken)
        print("user_mobile_access_token")
        print(user_mobile_access_token)
        let mobileSecret = String(describing: user_mobile_secret!)

        let parameter: Parameters = ["mobile_secret": mobileSecret, "code": String(describing: coinbaseInfoObject.accessToken!), "redirect_url": "com.coinbasepermittedcoinflash1.apps.coinflash-999://coinbase-oauth", "coinbase_refresh_access_token": String(describing: coinbaseInfoObject.refreshToken!)]
        SVProgressHUD.show(withStatus: "Linking Coinbase")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)auththirdparty3/", method: HTTPMethod.post, parameters: parameter)
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                    HelperFunctions.manageCoinBaseLinking()
                    self.tableView.reloadData()
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
    }
    
    func getCoinFlashUserInfo(){
        let mobileSecret = String(describing: user_mobile_secret!)
        print("getCoinflashUserInfo")
        let parameter: Parameters = ["mobile_secret": mobileSecret, "user_id_mobile": String(describing:user_id_mobile!), "mobile_access_token": String(describing:user_mobile_access_token!)]
        SVProgressHUD.show(withStatus: "Loading Account info")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)coinflashuser3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    print("GOT SUCCESS")
                    let json = JSON(value)
                    print(value)
                    let accounts = json[0]["plaid_accounts"].arrayValue
                    self.plaidAccounts = accounts
                    
                    self.tableView.reloadData()
                    // dismiss the progress hud
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                case .failure:
                    print("FAILURE")

                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
    }
    
    func addBankAccount() {
        presentPlaidLinkWithSharedConfiguration()
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
                self.getCoinFlashUserInfo()
                HelperFunctions.managePlaidLinked()
                self.tableView.reloadData()
                
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
    
    func DlinkBanksAndCoinbase(alert: UIAlertAction!) {
        if HelperFunctions.isPlaidLoggedIn() == true{
            
            DlinkPlaidCombine(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        }
        if HelperFunctions.isCoinbaseLoggedIn() == true{
            DlinkCoinbaseCombine(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
        }
    }
    
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
            case .success(_):
                SVProgressHUD.dismiss()
                
                HelperFunctions.manageCoinbaseDelinking()
                self.tableView.reloadData()
                
            case .failure:
                //   print(response.error as Any)
                SVProgressHUD.dismiss()
                
            }
            self.actionCount += 1
            if self.actionCount == 2 {
                AppDelegate.checkOnboardStatus()
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
                SVProgressHUD.dismiss()
                let DR = data?.value(forKey: "disconnect_returned")
                if DR != nil
                {
                    
                    HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                    plaidInfoObject.loggedIn = false
                    self.plaidAccounts = []
                    HelperFunctions.managePlaidDelinking()
                    
                }
                
                HelperFunctions.SaveBankInfo(m_token_id: "none", m_logged_in: "false")
                self.tableView.reloadData()
                
            case .failure:
                //    print(response.error as Any)
                SVProgressHUD.dismiss()
            }
            self.actionCount += 1
            if self.actionCount == 2 {
                AppDelegate.checkOnboardStatus()
            }
        }
    }
}

//// Plaid
extension SettingsViewController : PLKPlaidLinkViewDelegate
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
        
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 1
        }
        if plaidAccounts.count == 0 {
            plaidInfoObject.loggedIn = false
            return 1
        } else {
            plaidInfoObject.loggedIn = true
            return plaidAccounts.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as CardSettingCell
        cell.iconView.isHidden = true
        if indexPath.section == 1 {
            cell.iconView.isHidden = false
            cell.iconView.image = UIImage.init(named: "coinbase_card")
            cell.nameLabel.text = "Coinbase"
            cell.descLabel.text = HelperFunctions.isCoinbaseLoggedIn() ? "Account Linked." : "Relink account"
        } else if plaidAccounts.count == 0 {
            cell.iconView.image = UIImage.init(named: "visa_card")
            cell.nameLabel.text = "Bank Card"
            cell.descLabel.text = "Relink account"
        } else {
            cell.iconView.image = UIImage.init(named: "visa_card")
            cell.nameLabel.text = plaidAccounts[indexPath.row]["plaid_account_name"].string ?? "Bank"
            cell.descLabel.text = "**** **** ****\(plaidAccounts[indexPath.row]["last_four_digits"].stringValue)"
            HelperFunctions.managePlaidLinked()
        }
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if !HelperFunctions.isCoinbaseLoggedIn() {
                linkCoinbase()
            }
        } else {
            if plaidAccounts.count == 0 {
                addBankAccount()
            }
        }
    }
}
