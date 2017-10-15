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

class SettingsVC: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var monthlyButton: UIButton?
    @IBOutlet weak var weeklyButton: UIButton?
    @IBOutlet weak var investChangeControl: UISwitch!
    @IBOutlet weak var changeToInvestSlider: UISlider!
    @IBOutlet weak var changeToInvestSliderValueLabel: UILabel!
    @IBOutlet weak var capOnInvestmentTextField: UITextField!
    
    var tempChangeCapValue: Int! // Holds the current uptodate change cap value
    var tempCapOnInvestmentValue: Int! // Hols the current cap on investment value
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.loadGlobalSettings()
        
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
        let str = (textField.text! + string)
        if str.characters.count <= 4 {
            return true
        }
        textField.text = str.substring(to: str.index(str.startIndex, offsetBy: 10))
        return false
    }
    
    func cancelNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
        capOnInvestmentTextField.text = "$\(globalSettings.capOnInvestment!)"
    }
    
    func doneWithNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
        var temp = capOnInvestmentTextField.text!
        temp.remove(at: temp.startIndex)
        self.tempCapOnInvestmentValue = Int(temp)
        /*
        globalSettings.capOnInvestment = Int(temp)
        print(globalSettings.capOnInvestment)
         */
    }
    
    @IBAction func didTapOnBackButton(){
        self.navigationController?.popViewController(animated: true)
    }
    
    // tableview delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 1{
            return 70
        }
        if indexPath.row == 2{
            return 120
        }
        return UITableViewAutomaticDimension
    }
    
    //MARK: - Global settings functions
    // LOAD SAVE GLOBAL SETTINGS
    func loadGlobalSettings(){
        if globalSettings.investHowOften == .monthly{
            monthlyButton?.isSelected = true
            weeklyButton?.isSelected = false
        }else{
            monthlyButton?.isSelected = false
            weeklyButton?.isSelected = true
        }
        
        self.changeToInvestSlider.value = Float(globalSettings.percentOfChangeToInvest)
        self.changeToInvestSliderValueLabel.text = "\(Int(globalSettings.percentOfChangeToInvest))%"
        self.capOnInvestmentTextField.text = "$\(globalSettings.capOnInvestment!)"
    }
    
    // Saves global settings
    @IBAction func saveGlobalSettings(){
        self.requestToUpdateUserSettings()
        return()
        if monthlyButton?.isSelected == true{
            globalSettings.investHowOften = .monthly
        }else{
            globalSettings.investHowOften = .weekly
        }
        if investChangeControl.isOn == true{
            globalSettings.investChange = true
        }else{
            globalSettings.investChange = false
        }
        
        globalSettings.percentOfChangeToInvest = self.tempChangeCapValue
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
        
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "update_preferences": "true", "invest_change": investChange, "percent_to_invest": self.tempChangeCapValue,
                                     "how_often": howOften, "cap": self.tempCapOnInvestmentValue, "user_set_primary_coinbase_account_id": "",
                                     "user_set_primary_coinbase_btc_account_id":"", "User_set_primary_coinbase_eth_account_id":"",
                                     "user_set_primary_coinflash_debit_wallet_id":""]
        SVProgressHUD.show(withStatus: "Loading Account info")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)coinflashuser3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    // dismiss the progress hud
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
        
    }
}
