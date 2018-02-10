//
//  SettingsVC.swift
//  coinflash
//
//  Created by TJ on 9/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD
import SwiftyJSON

class SettingsVC: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    
    @IBOutlet weak var monthlyButton: UIButton?
    @IBOutlet weak var weeklyButton: UIButton?
    @IBOutlet weak var investChangeControl: UISwitch!
    @IBOutlet weak var changeToInvestSlider: UISlider!
    @IBOutlet weak var changeToInvestSliderValueLabel: UILabel!
    @IBOutlet weak var capOnInvestmentTextField: UITextField!
    @IBOutlet weak var coinbasePaymentMethodLabel: UILabel!
    @IBOutlet weak var ethWalletLabel: UILabel!
    @IBOutlet weak var btcWalletLabel: UILabel!
    @IBOutlet weak var TableCellViewCard: UITableViewCell!
    @IBOutlet weak var TableCellViewBTC: UITableViewCell!
    @IBOutlet weak var TableCellViewETH: UITableViewCell!
    
    @IBOutlet weak var validSubscriptionTextLabel: UILabel!
    @IBOutlet weak var validSubscriotionWarningIcon: UIImageView!
    
    var generalPickerView: UIPickerView!
    var pickerViewSupportingBackgroundView: UIView! // used to ensure user is not able to tap on tableview when pickerview is visible.
    var pickerViewSupportingGestureRecognizer: UITapGestureRecognizer! // used to dismiss pickerview when a user taps on pickerviewsupportingbackgroundview
    var showingPickerWithDataSource: Int! // 1 = coinbae card, 2 = btc wallet, 3 = eth wallet
    
    var tempChangeCapValue: Int! // Holds the current uptodate change cap value
    var tempCapOnInvestmentValue: Int! // Hols the current cap on investment value
    var coinbaseAccounts: JSON! // coinbase accounts
    var coinbasePrimaryAccountID: String! // the primary id of selected coinbase account
    var ethWalletAccounts: [JSON]! // ether wallet accounts
    var ethPrimaryWalletAccountID: String! // the primary id of ether wallet set by user
    var btcWalletAccounts: [JSON]! // btc wallet accounts
    var btcPrimaryWalletAccountsID: String! // the primary id of btc wallet set by user
    var plaid_error_code : Int!
    var pickerViewData: [String]!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // CapOnInvestmentTextField initializations
        capOnInvestmentTextField.delegate = self
        capOnInvestmentTextField.returnKeyType = .done
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        capOnInvestmentTextField.inputAccessoryView = numberToolbar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named:"bg.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        self.addPickerViewToViewController()
        
        self.loadGlobalSettings()
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        /// Check if subscription is active or not
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == true{
            // format the expiry date
            let dateFormate = DateFormatter()
            dateFormate.dateStyle = .medium
            self.validSubscriptionTextLabel.text = "Active" // \(dateFormate.string(from: (StoreKitHelper.sharedInstance.monthlySubscriptionExpiryDate!)))"
            if StoreKitHelper.sharedInstance.monthlySubscriptionState == .managedOnWebsite{
                self.validSubscriptionTextLabel.text = "Not Active"
            }
            self.validSubscriotionWarningIcon.isHidden = true
        }else{
            self.validSubscriotionWarningIcon.isHidden = false
            self.validSubscriptionTextLabel.text = "Not Active"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // Nav pop with swipe recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //Setting taps actions
    @IBAction func didTapOnMonthlyWeekly(sender: UIButton){
        if sender == monthlyButton{
            if sender.isSelected == false{
                sender.isSelected = true
                weeklyButton?.isSelected = false
                
            }
           // else if sender.isSelected == true{
           //     sender.isSelected = false
           //     weeklyButton?.isSelected = true
           // }
        }
        
        if sender == weeklyButton{
            if sender.isSelected == false{
                sender.isSelected = true
                monthlyButton?.isSelected = false
            }
           // else if sender.isSelected == true{
           //     sender.isSelected = false
           //     monthlyButton?.isSelected = true
           // }
        }
    }
    
    //Slider chnages
    @IBAction func changeToInvestSliderChanged(sender: UISlider){
        self.tempChangeCapValue = Int(sender.value)
        self.changeToInvestSliderValueLabel.text = "\(Int(sender.value))%"
    }
    
    //Cap on investment TextField saved
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = (textField.text! + string)
        
        
        if Int(str) == nil{
            str = "100"
            textField.text = str
            
            return false
        }
        var check = Int(str)!
        if check > 500{
            str = "500"
            textField.text = str
            return false
        }
        if str.characters.count <= 3 {
            return true
        }
        
        //textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 10))
        textField.text = str.substring(to: str.index(str.startIndex, offsetBy:3))
        //textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 10)
        return false
    }
    
    func cancelNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
        capOnInvestmentTextField.text = "\(globalSettings.capOnInvestment!)"
    }
    
    func doneWithNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
        var temp = capOnInvestmentTextField.text!
        //temp.remove(at: temp.startIndex)
        self.tempCapOnInvestmentValue = Int(temp)
        /*
        globalSettings.capOnInvestment = Int(temp)
        print(globalSettings.capOnInvestment)
         */
    }
    
    @IBAction func didTapOnBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Global settings functions
    // LOAD SAVE GLOBAL SETTINGS
    func loadGlobalSettings(){
        hideParemeters()
        if globalSettings.investHowOften == .monthly{
            monthlyButton?.isSelected = true
            weeklyButton?.isSelected = false
        }else{
            monthlyButton?.isSelected = false
            weeklyButton?.isSelected = true
        }
        if globalSettings.investChange == true{
            
            self.investChangeControl.isOn = true
        }
        else{
            self.investChangeControl.isOn = false
        }
        self.changeToInvestSlider.value = Float(globalSettings.percentOfChangeToInvest)
        self.changeToInvestSliderValueLabel.text = "\(Int(globalSettings.percentOfChangeToInvest))%"
        self.capOnInvestmentTextField.text = "\(globalSettings.capOnInvestment!)"
        
        self.tempCapOnInvestmentValue = globalSettings.capOnInvestment
        self.tempChangeCapValue = globalSettings.percentOfChangeToInvest
        
        
        TableCellViewCard.isHidden = true
        TableCellViewBTC.isHidden = true
        TableCellViewETH.isHidden = true
        
        // load the accounts
        // loading coinbase accounts
        self.coinbaseAccounts = globalCoinflashUser3ResponseValue["coinbase_accounts"]
        let wallets = globalCoinflashUser3ResponseValue["wallets"]
        for (index,subJson):(String, JSON) in self.coinbaseAccounts {
            //Do something you want
           // print(subJson)
            if subJson["type"] == "fiat_account"{
                self.coinbaseAccounts.arrayObject?.remove(at: Int(index)!)
                continue
            }
            if subJson["id"].string == self.coinbasePrimaryAccountID{
               // print("this is primary")
            }else{
              //  print("not primary")
            }
            if globalCoinflashUser3ResponseValue["user_set_primary_coinbase_account_id"] == JSON.null{
                // get the first account and set it to primary coinbase account
                if index == "0"{
                    self.coinbasePaymentMethodLabel.isHidden = false
                    self.coinbasePaymentMethodLabel.text = subJson["name"].string
                    self.coinbasePrimaryAccountID = subJson["id"].string
                    TableCellViewCard.isHidden = false
                }
            }else{
                // find the coinbase wallet account and set its title in view
                self.coinbasePrimaryAccountID = globalCoinflashUser3ResponseValue["user_set_primary_coinbase_account_id"].string
                for (_, subJson):(String, JSON) in coinbaseAccounts{
                    //print(subJson["id"].string)
                    TableCellViewCard.isHidden = false
                    if subJson["id"] == globalCoinflashUser3ResponseValue["user_set_primary_coinbase_account_id"]{
                        self.coinbasePaymentMethodLabel.text = subJson["name"].string
                    }
                }
            }
        }
      //  print(self.coinbaseAccounts)
        
        self.ethPrimaryWalletAccountID = globalCoinflashUser3ResponseValue["user_set_primary_coinbase_eth_account_id"].string
        self.btcPrimaryWalletAccountsID = globalCoinflashUser3ResponseValue["user_set_primary_coinbase_btc_account_id"].string
        self.plaid_error_code = globalCoinflashUser3ResponseValue["plaid_error_code"].int
        
        
        ethWalletAccounts = [JSON]()
        btcWalletAccounts = [JSON]()
        
        
        for (index, subJson):(String, JSON) in wallets{
            
            if subJson["currency"]["code"] == "ETH" && subJson["type"] == "wallet"{
                ethWalletAccounts.append(subJson)
            }
            if subJson["currency"]["code"] == "BTC" && subJson["type"] == "wallet"{
                btcWalletAccounts.append(subJson)
            }
        }
        
        // Check the default eth wallet account and set the label in ui
        for json in ethWalletAccounts{
            if json["id"].string == self.ethPrimaryWalletAccountID{
                ethWalletLabel.text = json["name"].string
            }
            TableCellViewETH.isHidden = false
            self.ethWalletLabel.isHidden = false
        }
        
        // Check the default btc wallet account and set the label in ui
        for json in btcWalletAccounts{
            if json["id"].string == self.btcPrimaryWalletAccountsID{
                btcWalletLabel.text = json["name"].string
            }
            TableCellViewBTC.isHidden = false
            btcWalletLabel.isHidden = false
        }
        
        // if no default eth primary wallet set then get the first one and make it primary
       // print(globalCoinflashUser3ResponseValue["user_set_primary_coinbase_eth_account_id"].string)
        if globalCoinflashUser3ResponseValue["user_set_primary_coinbase_eth_account_id"] == JSON.null || globalCoinflashUser3ResponseValue["user_set_primary_coinbase_eth_account_id"].string == ""{
            if ethWalletAccounts.count > 0{
                ethWalletLabel.text = ethWalletAccounts[0]["name"].string
                self.ethPrimaryWalletAccountID = ethWalletAccounts[0]["id"].string
            }
        }
        
        // if no default btc primary wallet set.. then get the first one and make it primary
        if globalCoinflashUser3ResponseValue["user_set_primary_coinbase_btc_account_id"] == JSON.null || globalCoinflashUser3ResponseValue["user_set_primary_coinbase_btc_account_id"].string == ""{
            if btcWalletAccounts.count > 0{
                btcWalletLabel.text = btcWalletAccounts[0]["name"].string
                self.btcPrimaryWalletAccountsID = btcWalletAccounts[0]["id"].string
            }
        }
    }
    
    // Saves global settings
    @IBAction func saveGlobalSettings(){
        self.requestToUpdateUserSettings()
    }
    
    //MARK: - TableView
    // tableview delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 1{
            return 70
        }
        if indexPath.row == 2{
            return 120
        }
        
        /// Check if subscription is active or not
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == true{
            // format the expiry date
            let dateFormate = DateFormatter()
            dateFormate.dateStyle = .medium
            self.validSubscriptionTextLabel.text = "Active" // \(dateFormate.string(from: (StoreKitHelper.sharedInstance.monthlySubscriptionExpiryDate!)))"
            if StoreKitHelper.sharedInstance.monthlySubscriptionState == .managedOnWebsite{
                self.validSubscriptionTextLabel.text = "Not Active"
            }
            self.validSubscriotionWarningIcon.isHidden = true
        }else{
            self.validSubscriotionWarningIcon.isHidden = false
            self.validSubscriptionTextLabel.text = "Not Active"
        }
        
        if indexPath.row == 3{
            return 0
        }
        
        if indexPath.row == 5{
            if TableCellViewCard.isHidden == true{
                return 0
            }
        }
        
        if indexPath.row == 6{
            // check whether to show eth and btc wallets or not
            if btcWalletAccounts.count < 0{
                return 0
            }
            if TableCellViewBTC.isHidden == true{
                //return 0
            }
            return 0
        }
        if indexPath.row == 7{
            if ethWalletAccounts.count < 0{
                return 0
            }
            if TableCellViewETH.isHidden == true{
                //return 0
            }
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5{
            self.pickerViewData = nil
            self.showingPickerWithDataSource = 1
            pickerViewData = [String]()
            for (index,subJson):(String, JSON) in self.coinbaseAccounts {
                //Do something you want
             //   print(subJson["name"].string)
                pickerViewData.append(subJson["name"].string!)
            }
            self.showPickerView()
        }
        if indexPath.row == 6{
          //  print("bitcoin wallet cell")
            self.showingPickerWithDataSource = 2
            self.pickerViewData = nil
            pickerViewData = [String]()
            for json in btcWalletAccounts{
                pickerViewData.append(json["name"].string!)
            }
            self.showPickerView()
        }
        if indexPath.row == 7{
         //   print("ether wallet cell")
            self.showingPickerWithDataSource = 3
            self.pickerViewData = [String]()
            for json in ethWalletAccounts{
                pickerViewData.append(json["name"].string!)
            }
            self.showPickerView()
        }
        
        // set the pickerview selected row
        if showingPickerWithDataSource == 1{
            for (index, subJson):(String, JSON) in coinbaseAccounts{
                if subJson["id"].string == self.coinbasePrimaryAccountID{
                    self.generalPickerView.selectRow(Int(index)!, inComponent: 0, animated: true)
                }
            }
        }else if showingPickerWithDataSource == 2{
            for (index, json) in btcWalletAccounts.enumerated(){
                if json["id"].string == self.btcPrimaryWalletAccountsID{
                    self.generalPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }else if showingPickerWithDataSource == 3{
            for (index, json) in ethWalletAccounts.enumerated(){
                if json["id"].string == self.ethPrimaryWalletAccountID{
                    self.generalPickerView.selectRow(index, inComponent: 0, animated: true)
                }
            }
        }
    }
    
    //MARK: - API REQUESTS
    func requestToUpdateUserSettings(){
        var investChange: Int!
        if investChangeControl.isOn == true{
            investChange = 1
        }else{
            investChange = 0
        }
        let howOften: Int!
        if monthlyButton?.isSelected == true{
            howOften = 3
        }else{
            howOften = 2
        }
        
        // process the tempCapOnInvestment
        self.doneWithNumberPad()
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "update_preferences": "true", "invest_change": investChange, "percent_to_invest": self.tempChangeCapValue,
                                     "how_often": howOften, "cap": self.tempCapOnInvestmentValue,
                                     "user_set_primary_coinbase_account_id": self.coinbasePrimaryAccountID,
                                     "user_set_primary_coinbase_btc_account_id":self.btcPrimaryWalletAccountsID, "User_set_primary_coinbase_eth_account_id":self.ethPrimaryWalletAccountID,
                                     "user_set_primary_coinflash_debit_wallet_id":""]
        SVProgressHUD.show(withStatus: "Updating Info")
        Alamofire.request("\(baseUrl)coinflashuser3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    // dismiss the progress hud
                    SVProgressHUD.dismiss()
                    if self.monthlyButton?.isSelected == true{
                        globalSettings.investHowOften = .monthly
                    }else{
                        globalSettings.investHowOften = .weekly
                    }
                    if self.investChangeControl.isOn == true{
                        globalSettings.investChange = true
                    }else{
                        globalSettings.investChange = false
                    }
                    globalSettings.percentOfChangeToInvest = self.tempChangeCapValue
                    
                    globalSettings.percentOfChangeToInvest = self.tempChangeCapValue
                    globalSettings.capOnInvestment = self.tempCapOnInvestmentValue
                    if investChange == 1{
                        globalSettings.investChange = true
                    }else{
                        globalSettings.investChange = false
                    }
                    
                    // MANIPULATE THE USER3 Response global object
                    globalCoinflashUser3ResponseValue["user_set_primary_coinbase_account_id"].string = self.coinbasePrimaryAccountID
                    globalCoinflashUser3ResponseValue["user_set_primary_coinbase_btc_account_id"].string = self.btcPrimaryWalletAccountsID
                    globalCoinflashUser3ResponseValue["User_set_primary_coinbase_eth_account_id"].string = self.ethPrimaryWalletAccountID
                    
                case .failure:
                 //   print(response.error as Any)
                    SVProgressHUD.dismiss()
                    self.loadGlobalSettings()
                    let alert = UIAlertController(title: "Error", message: "Kindly check your internet connection and retry", preferredStyle: UIAlertControllerStyle.alert)
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert) in
                        
                    })
                    let retry = UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: { (alert) in
                        self.saveGlobalSettings()
                    })
                    alert.addAction(cancel)
                    alert.addAction(retry)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    //MARK: - PickerView
    func addPickerViewToViewController(){
        // create the background to disable touches going to main viewcontroller when picker is showing
        self.pickerViewSupportingBackgroundView = UIView(frame: self.view.frame)
        self.pickerViewSupportingBackgroundView.backgroundColor = UIColor.black
        self.pickerViewSupportingBackgroundView.isOpaque = false
        self.pickerViewSupportingBackgroundView.alpha = 0.5
        self.view.addSubview(self.pickerViewSupportingBackgroundView)
        self.pickerViewSupportingBackgroundView.isHidden = true
        
        // add gesture recognizer to the view
        self.pickerViewSupportingGestureRecognizer = UITapGestureRecognizer()
        self.pickerViewSupportingGestureRecognizer.numberOfTapsRequired = 1
        self.pickerViewSupportingGestureRecognizer.addTarget(self, action: #selector(didTapOnGestureToDismissPickerView))
        self.pickerViewSupportingBackgroundView.addGestureRecognizer(self.pickerViewSupportingGestureRecognizer)
        
        self.generalPickerView = UIPickerView()
        self.generalPickerView.delegate = self
        self.generalPickerView.dataSource = self
        self.generalPickerView.backgroundColor = UIColor.white
        self.generalPickerView.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y + self.view.frame.height - self.view.frame.height/3, width: self.view.frame.size.width, height: self.view.frame.height/3)
        self.view.addSubview(self.generalPickerView)
        self.generalPickerView.isHidden = true
        //self.showPickerView()
    }
    
    func didTapOnGestureToDismissPickerView(){
        self.hidePickerView()
    }
    
    func showPickerView(){
        self.generalPickerView.reloadAllComponents()
        self.pickerViewSupportingBackgroundView.isHidden = false
        self.generalPickerView.isHidden = false
    }
    
    func hidePickerView(){
        self.generalPickerView.isHidden = true
        self.pickerViewSupportingBackgroundView.isHidden = true
        
        /// set the labels and values based on the selected row
        let row = generalPickerView.selectedRow(inComponent: 0)
        
        if showingPickerWithDataSource == 1 && coinbaseAccounts.count != 0{
            //print(coinbaseAccounts[row]["id"].string)
            self.coinbasePrimaryAccountID = coinbaseAccounts[row]["id"].string
            self.coinbasePaymentMethodLabel.text = coinbaseAccounts[row]["name"].string
        }else if showingPickerWithDataSource == 2 && btcWalletAccounts.count != 0 {
            
            self.btcPrimaryWalletAccountsID = btcWalletAccounts[row]["id"].string
            self.btcWalletLabel.text = btcWalletAccounts[row]["name"].string
        }else if showingPickerWithDataSource == 3 && ethWalletAccounts.count != 0{
            self.ethPrimaryWalletAccountID = ethWalletAccounts[row]["id"].string
            self.ethWalletLabel.text = ethWalletAccounts[row]["name"].string
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.pickerViewData != nil{
            return self.pickerViewData[row]
        }else{
            return "No Wallets/ Cards Set"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.pickerViewData == nil{
            return 1
        }else{
            return self.pickerViewData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      //  print(row)
        if showingPickerWithDataSource == 1{
            self.coinbasePrimaryAccountID = coinbaseAccounts[row]["id"].string
            self.coinbasePaymentMethodLabel.text = coinbaseAccounts[row]["name"].string
        }else if showingPickerWithDataSource == 2{
            self.btcPrimaryWalletAccountsID = btcWalletAccounts[row]["id"].string
            self.btcWalletLabel.text = btcWalletAccounts[row]["name"].string
        }else if showingPickerWithDataSource == 3{
            self.ethPrimaryWalletAccountID = ethWalletAccounts[row]["id"].string
            self.ethWalletLabel.text = ethWalletAccounts[row]["name"].string
        }
    }
    
    func hideParemeters(){
        self.coinbasePaymentMethodLabel.isHidden  = false
        self.ethWalletLabel.isHidden = false
        self.btcWalletLabel.isHidden = false
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "in-app-purchase-segue"{
            /// If subscription is managed on website... then we dont transition to the in app purchase page
            //if StoreKitHelper.sharedInstance.monthlySubscriptionState == .managedOnWebsite{
            //    return false
           // }
            // If user has a valid subscription... then no need to transition forward
            if StoreKitHelper.sharedInstance.monthlySubscriptionState == .valid{
                //return true
            }
        }
        return true
    }
}
