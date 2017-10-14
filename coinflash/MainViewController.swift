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
    
    @IBAction func InvestmentRateSlider(_ sender: Any) {
        let Rate = SliderinvestmentRateDecider?.value
        self.LabelBitcoinInvestmentRate?.text = String(format:"%.0f", Rate!) + "$"
        self.LabelEtherInvestmentRate?.text = String(format:"%.0f", (100 - Rate!)) + "$"
        
    }
    func saveBankDetailsInemory(token_id : String){
        var singleBankDetails = plaidInfoObject
        singleBankDetails.accessToken = token_id
        PlaidBankInfoData.append(singleBankDetails)
        HelperFunctions.SaveBankInfo()
        
    }
    func loadBankDetails(){
        
        HelperFunctions.LoadBankInfo()
        
    }
    
    @IBAction func TestPlaid(_ sender: Any) {
        presentPlaidLinkWithSharedConfiguration()
    }
    
    @IBAction func TestPlidAction(_ sender: Any) {
        //presentPlaidLinkWithSharedConfiguration()

    }
    
    override func viewDidLoad() {
        SideMenuManager.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.menuDismissOnPush = true
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuParallaxStrength = 3
        self.requestCoinFlashFeatchccTransations(mobile_secret: "8dkkaiei20kdjkwoeo29ddkskalw82asD!", user_id_mobile: "1", mobile_access_token: "3f506ad810db4baba56493fcd25799")
        self.loadBankDetails()
        
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
    
    
    func LinkPlaid(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,bank_token: String,public_token :String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "mobile_access_token" : public_token
            
            ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/coinflashtransactions3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            
            if let array = response.result.value as? NSArray {
                for obj in array {
                    if let dict = obj as? NSDictionary {
                        var singleTransation = TCryptoInfo_global
                        
                        singleTransation?.TCryptoInfo_crypto  = dict.value(forKey: "coinbase_crypto_amount") as! String
                       
                    }
                }
            }
            // Loading the data in the Table
            
            SVProgressHUD.dismiss()
        }
    }
    func DlinkPlaid(){
        
        
        
    }
    
    
    
    ///////////////////////////////////// PLAID //////////////////////////////////////
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        self.saveBankDetailsInemory(token_id: publicToken)
        presentAlertViewWithTitle("Success", message: "token: \(publicToken)\nmetadata: \(metadata ?? [:])")
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
        // <!-- SMARTDOWN_PRESENT_SHARED -->
        // With shared configuration from Info.plist
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
        // <!-- SMARTDOWN_PRESENT_SHARED -->
    }
    
    // MARK: Plaid Link setup with custom configuration
    func presentPlaidLinkWithCustomConfiguration() {
        // <!-- SMARTDOWN_PRESENT_CUSTOM -->
        // With custom configuration
        let linkConfiguration = PLKConfiguration(key: "93bf429075d0e7ff0fc28750127c45", env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
        // <!-- SMARTDOWN_PRESENT_CUSTOM -->
    }
    
}



//// Plaid
extension MainViewController : PLKPlaidLinkViewDelegate
    // <!-- SMARTDOWN_PROTOCOL -->
{
    
    // <!-- SMARTDOWN_DELEGATE_SUCCESS -->
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            // Handle success, e.g. by storing publicToken with your service
            self.saveBankDetailsInemory(token_id: publicToken)
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    // <!-- SMARTDOWN_DELEGATE_SUCCESS -->
    
    // <!-- SMARTDOWN_DELEGATE_EXIT -->
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
                //self.handleError(error, metadata: metadata)
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
                //self.handleExitWithMetadata(metadata)
            }
        }
    }
    // <!-- SMARTDOWN_DELEGATE_EXIT -->
    
    // <!-- SMARTDOWN_DELEGATE_EVENT -->
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: \(event)\nmetadata: \(metadata)")
    }
    // <!-- SMARTDOWN_DELEGATE_EVENT -->
}

