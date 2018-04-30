//
//  PreferencesViewController.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
import ActionSheetPicker_3_0
import MBProgressHUD

class PreferencesViewController: UIViewController, MainNewStoryboardInstance {
    
    @IBOutlet weak var coin1Label: UILabel!
    @IBOutlet weak var coin1Icon: UIImageView!
    @IBOutlet weak var coin2Label: UILabel!
    @IBOutlet weak var coin2Icon: UIImageView!
    @IBOutlet weak var percentageChangeInvestedLabel: UILabel!
    @IBOutlet weak var coin1NameDist: UILabel!
    @IBOutlet weak var coin1Dist: UILabel!
    @IBOutlet weak var coin2Dist: UILabel!
    @IBOutlet weak var coin2NameDist: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var subscriptionStatusLabel: UILabel!
    @IBOutlet weak var warningIcon: UIImageView!
    
    @IBOutlet weak var investTypeSegment: CustomSegmentedControl!
    
    @IBOutlet weak var distributionSlider: UISlider!
    @IBOutlet weak var changeInvestSlider: UISlider!
    
    let handler = ManageChangeHandler.sharedInstance
    
    var coin1: CoinType?
    var coin2: CoinType?
    var selectedCoinbaseAccount: CoinbaseAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        investTypeSegment.items = ["OFF", "WEEKLY", "MONTHLY"]
        
        let leftTrackImage = UIImage(named: "slider-orange")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0))
        let rightTrackImage = UIImage(named: "slider-blue")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0))
        distributionSlider.setMinimumTrackImage(leftTrackImage, for: .normal)
        distributionSlider.setMaximumTrackImage(rightTrackImage, for: .normal)
        distributionSlider.setThumbImage(UIImage(named: "slider-track"), for: .normal)
        
        let grayTrackImage = UIImage(named: "slider-gray")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0))
        changeInvestSlider.setMinimumTrackImage(rightTrackImage, for: .normal)
        changeInvestSlider.setMaximumTrackImage(grayTrackImage, for: .normal)
        changeInvestSlider.setThumbImage(UIImage(named: "slider-track-blue"), for: .normal)
        
        distributionSlider.addTarget(self, action: #selector(distributionSliderEndedEditing), for: .touchUpInside)
        changeInvestSlider.addTarget(self, action: #selector(changeSliderEndedEditing), for: .touchUpInside)
        investTypeSegment.addTarget(self, action: #selector(howOftenValueChanged), for: .valueChanged)
        
        updateViews()
        refreshData()
    }
    
    private func refreshData() {
        MBProgressHUD.showAdded(to: view, animated: true)
        handler.requestCoinflashUser5 { [weak self] (success) in
            guard let strongSelf = self else { return }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            if success {
                strongSelf.updateViews()
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func coinChangeButtonPressed(_ sender: Any) {
        guard let coin1 = coin1, let coin2 = coin2 else {
            return
        }
        let allCoins = CoinType.coins
        var coin1Index = 0
        var coin2Index = 0
        for i in 0..<allCoins.count {
            let coin = allCoins[i]
            if coin == coin1 {
                coin1Index = i
            }
            if coin == coin2 {
                coin2Index = i
            }
        }
        let coinMaps = allCoins.map({$0.fullName})
        ActionSheetMultipleStringPicker.show(withTitle: "Select coin pair", rows: [coinMaps, coinMaps], initialSelection: [coin1Index, coin2Index], doneBlock: { (_, indexes, values) in
            guard let indexes = indexes as? [Int], indexes.count == 2 else {
                return
            }
            let index1 = indexes[0]
            let index2 = indexes[1]
            if index1 == index2 {
                self.showAlert(title: "Error", message: "You must select 2 different coins.")
                return
            }
            let coin11 = allCoins[index1]
            let coin22 = allCoins[index2]
            self.updateCoinPair(coin1: coin11, coin2: coin22)
        }, cancel: { (_) in
            
        }, origin: sender)
    }
    
    @IBAction func subscriptionButtonPressed(_ sender: Any) {
        let vc = InAppPurchaseVC.storyboardInstance() as InAppPurchaseVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func distributionSliderChanged(_ sender: Any) {
        let leftValue = Int(distributionSlider.value)
        coin1Dist.text = "\(100 - leftValue)%"
        coin2Dist.text = "\(leftValue)%"
    }
    
    @objc func distributionSliderEndedEditing() {
        guard let coin1 = coin1, let coin2 = coin2 else {
            return
        }
        updateCoinPair(coin1: coin1, coin2: coin2)
    }
    
    @objc func changeSliderEndedEditing() {
        saveButtonPressed()
    }
    
    @objc func howOftenValueChanged() {
        saveButtonPressed()
    }
    
    @IBAction func coinbasePaymentButtonPressed(_ sender: Any) {
        guard let accounts = handler.change?.coinbaseAccounts, accounts.count > 0 else {
            return
        }
        let accs = accounts.map { $0.name }
        var initIndex = 0
        for i in 0..<accounts.count {
            let ac = accounts[i]
            if selectedCoinbaseAccount != nil, ac.id == selectedCoinbaseAccount!.id {
                initIndex = i
            }
        }
        let picker = ActionSheetStringPicker(title: "Coinbase payment method", rows: accs,
                                             initialSelection: initIndex,
                                             doneBlock: { (_, index, value) in
            self.selectedCoinbaseAccount = accounts[index]
            self.paymentMethodLabel.text = self.selectedCoinbaseAccount?.name
            self.saveButtonPressed()
        }, cancel: nil, origin: self.view)
        picker?.show()
    }
    
    func saveButtonPressed() {
        let investChange = (investTypeSegment.selectedSegmentIndex == 0) ? 0 : 1
        let howOften: HowOftenType = investTypeSegment.selectedSegmentIndex == 1 ? .weekly : .monthly
        let tempChangeCapValue = Int(changeInvestSlider.value)
        let cap = handler.preference?.cap ?? ""
        var parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "update_preferences": "true", "invest_change": investChange, "percent_to_invest": tempChangeCapValue,
                                     "how_often": howOften.rawValue, "cap": cap, "invest_on": investChange]
        if let account = selectedCoinbaseAccount {
            parameter["user_set_primary_coinbase_account_id"] = account.id
        }
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
                    self.handler.preference?.how_often = howOften
                    self.handler.preference?.invest_on = investChange
                    self.handler.preference?.percent_to_invest = tempChangeCapValue
                    self.handler.change?.invest_on = investChange
                    self.handler.change?.how_often = howOften.rawValue
                    self.handler.needRefreshData = true
                    if let account = self.selectedCoinbaseAccount {
                        self.handler.change?.user_set_primary_coinbase_account_id = account.id
                    }
                    
                case .failure:
                    //   print(response.error as Any)
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Save data failed. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (alert) in
                        
                    })
                    alert.addAction(cancel)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    private func updateViews() {
        paymentMethodLabel.text = ""
        guard let change = handler.change, let pref = handler.preference else {
            return
        }
        
        coin1 = change.left_side
        coin2 = change.right_side
        updateCoinViews()
        
        percentageChangeInvestedLabel.text = "\(pref.percent_to_invest)%"
        changeInvestSlider.value = Float(pref.percent_to_invest)
        if pref.invest_on > 0 {
            investTypeSegment.selectedSegmentIndex = pref.how_often == .weekly ? 1 : 2
        } else {
            investTypeSegment.selectedSegmentIndex = 0
        }
        
        /// Check if subscription is active or not
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == true{
            // format the expiry date
            let dateFormate = DateFormatter()
            dateFormate.dateStyle = .medium
            self.subscriptionStatusLabel.text = "Active" // \(dateFormate.string(from: (StoreKitHelper.sharedInstance.monthlySubscriptionExpiryDate!)))"
            if StoreKitHelper.sharedInstance.monthlySubscriptionState == .managedOnWebsite{
                self.subscriptionStatusLabel.text = "Not Active"
            }
            warningIcon.isHidden = true
        } else {
            warningIcon.isHidden = false
            self.subscriptionStatusLabel.text = "Not Active"
        }
        
        // coinbase account
        let coinbaseAccounts = change.coinbaseAccounts
        
        if change.user_set_primary_coinbase_account_id.isEmpty {
            for acc in coinbaseAccounts {
                if acc.type == "checking" {
                    selectedCoinbaseAccount = acc
                    paymentMethodLabel.text = acc.name
                    break
                }
            }
            if selectedCoinbaseAccount == nil {
                selectedCoinbaseAccount = coinbaseAccounts.first
                paymentMethodLabel.text = coinbaseAccounts.first?.name
            }
        } else {
            for acc in coinbaseAccounts {
                if acc.id == change.user_set_primary_coinbase_account_id {
                    paymentMethodLabel.text = acc.name
                    selectedCoinbaseAccount = acc
                }
            }
        }
    }
    
    private func updateCoinViews() {
        coin1Icon.image = UIImage.init(named: coin1?.icon ?? "")
        coin2Icon.image = UIImage.init(named: coin2?.icon ?? "")
        coin1Label.text = coin1?.name
        coin2Label.text = coin2?.name
        
        distributionSlider.value = 100 - Float(handler.change?.btc_percentage ?? 0)
        coin1NameDist.text = coin1?.fullName
        coin2NameDist.text = coin2?.fullName
        coin1Dist.text = "\(handler.change?.btc_percentage ?? 0)%"
        coin2Dist.text = "\(100 - (handler.change?.btc_percentage ?? 0))%"
        
    }
    
    @IBAction func investSliderChanged(_ sender: Any) {
        self.percentageChangeInvestedLabel.text = "\(Int(changeInvestSlider.value))%"
    }

    private func updateCoinPair(coin1: CoinType, coin2: CoinType) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let value = Int(distributionSlider.value)
        let parameters: [String: Any] = [
            "mobile_secret" : user_mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : user_mobile_access_token,
            "slider_value" : value,
            "left_side" : coin1.rawValue,
            "right_side" : coin2.rawValue
        ]
        
        SVProgressHUD.show(withStatus: "Updating Info")
        Alamofire.request("https://coinflashapp.com/coinflashuser5/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result{
            case .success( _):
                let data = response.result.value as? NSDictionary
                let SliderUpdated = data?.value(forKey: "success")
                //let data = response.result.value as! [String: String]
                if SliderUpdated != nil
                {
                    self.coin1 = coin1
                    self.coin2 = coin2
                    self.handler.change?.left_side = coin1
                    self.handler.change?.right_side = coin2
                    self.handler.change?.btc_percentage = 100 - Int(value)
                }
                self.handler.needRefreshData = true
                self.updateCoinViews()
                SVProgressHUD.dismiss()
            case .failure:
                //print(response.error as Any)
                SVProgressHUD.dismiss()
            }
        }
    }
}
