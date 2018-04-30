//
//  ManageChangeViewController.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import SVProgressHUD
import Alamofire
import SwiftyJSON
import MBProgressHUD

enum TransactionType {
    case invested, unInvested
}

class ManageChangeViewController: UIViewController, MainNewStoryboardInstance {
    
    @IBOutlet weak var tableView: UITableView!
    let handler = ManageChangeHandler.sharedInstance
    var currentTransactionType: TransactionType = .unInvested
    
    var lastRefreshDate: Date?
    var isLoadingData = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ManageChangeChartCell.self)
        tableView.register(ManageChangeSegmentCell.self)
        tableView.register(ManageChangeHistoryCell.self)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSuccessfullyBuyCoins(handleNotification:)), name: NSNotification.Name.onSuccessfulPurchaseOfCoins, object: nil)
        
        if !HelperFunctions.isCoinbaseLoggedIn() && !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: "Connect your coinbase account and bank to start investing.", style: .danger)
            banner.show()
        } else if !HelperFunctions.isPlaidLoggedIn(){
            let banner = NotificationBanner(title: "", subtitle: " Connect your bank to start investing.", style: .danger)
            banner.show()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        refreshDataIfNeeded()
    }
    
    func appDidBecomeActive() {
        if self.tabBarController?.selectedIndex == 0 {
            refreshDataIfNeeded()
        }
    }
    
    private func refreshDataIfNeeded() {
        let needRefreshExpired = shouldRefreshDateIfExpired()
        if needRefreshExpired || handler.needRefreshData {
            getCoinFlashUser5()
            handler.needRefreshData = false
        }
    }
    
    func shouldRefreshDateIfExpired()-> Bool {
        guard let date = lastRefreshDate else {
            return true
        }
        let dif = Date().timeIntervalSince(date)
        if dif >= 300 {
            return true
        }
        return false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    @IBAction func preferenceButtonPressed(_ sender: Any) {
        let vc = PreferencesViewController.storyboardInstance() as PreferencesViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSuccessfullyBuyCoins(handleNotification notificaiton: NSNotification){
        let banner = NotificationBanner(title: "Success", subtitle: "You successfully bought cyrptocurrency using your spare change.", style: .success)
        banner.show()
    }
    
    private func getCoinFlashUser5() {
        if isLoadingData {
            return
        }
        isLoadingData = true
        MBProgressHUD.showAdded(to: view, animated: true)
        handler.requestCoinflashUser5 { [weak self] (success) in
            guard let strongSelf = self else { return }
            strongSelf.lastRefreshDate = Date()
            strongSelf.isLoadingData = false
            if success {
                
                strongSelf.getTransactions()
            } else {
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                strongSelf.showAlert(title: "Error", message: "Ooops. Cannot get data. Please try again")
            }
        }
    }
    
    private func getTransactions() {
        handler.requestCoinFlashFeatchccTransations { [weak self] (success) in
            guard let strongSelf = self else { return }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            
            if success {
                strongSelf.processTransactionsData()
            }
            strongSelf.processUserData()
        }
    }
    
    private func processUserData() {
        guard let change = handler.change else {
            return
        }
        let howPaying = change.how_paying
        if howPaying == 1 {
            StoreKitHelper.sharedInstance.monthlySubscriptionState = .managedOnWebsite
        } else if howPaying == 0 {
            StoreKitHelper.sharedInstance.monthlySubscriptionState = .notPurchased
        }
        
        // check if plaid needs relinking
        var plaidNeedsRelinking = false
        if change.plaid_error_code == 2 {
            plaidNeedsRelinking = true
        }
        // check if coinbase needs relinking
        var coinbaseNeedsRelinking = false
        if let first = change.json["wallets"].arrayValue.first {
            if first.string != nil {
                coinbaseNeedsRelinking = true
            }
        }
        
        if coinbaseNeedsRelinking == true && plaidNeedsRelinking == true{
            
            self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase and Bank account.  Please unlink and relink your bank and coinbase to resolve this issue.")
        } else if coinbaseNeedsRelinking == true{
            self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Coinbase account.  Please unlink and relink your Coinbase account to resolve this issue.")
        } else if plaidNeedsRelinking == true{
            self.showConfirmationDialogBox(title: "Error", Message: "Error connecting with Bank account.  Please unlink and relink your bank to resolve this issue.")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    private func processTransactionsData() {
        
    }
    
    private func showConfirmationDialogBox(title : String , Message : String)
    {
        let alert = UIAlertController(title: title, message: Message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func buyNow() {
        /// Check if user has subscription:
        let testing = false
        if StoreKitHelper.sharedInstance.userHasValidMonthlySubscription() == false && testing == false{
            let alert = UIAlertController(title: "", message: "Coinflash charges $1 a month for this feature, go to settings to set up your subscription.", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                let vc = InAppPurchaseVC.storyboardInstance() as InAppPurchaseVC
                self.navigationController?.pushViewController(vc, animated: true)
            })
            let buyAction = UIAlertAction(title: "Buy Now", style: UIAlertActionStyle.default, handler: { (alertAction) in
                let vc = InAppPurchaseVC.storyboardInstance() as InAppPurchaseVC
                self.navigationController?.pushViewController(vc, animated: true)
            })
            alert.addAction(action)
            alert.addAction(buyAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        /// checking if there is a coinbase account with allow_buy = true
        var allow_buy = false
        guard let change = handler.change,
            let pref = handler.preference,
            let firstCoin = change.left_side,
            let secondCoin = change.right_side else { return }
        if change.json["coinbase_accounts"] != JSON.null{
            let accounts = change.json["coinbase_accounts"]
            for (_,subJson):(String, JSON) in accounts {
                if subJson["allow_buy"].bool == true{
                    allow_buy = true
                }
            }
        }
        
        // if allow buy true then else show error
        //let testing = false
        if allow_buy == true || testing == true{
            //HelperFunctions.showToast(withString: "Buying is allowed", onViewController: self)
            let dollars = pref.spare_change_accrued_percent_to_invest
            let dollarsToBuyBtc = pref.spare_change_accrued_percent_to_invest * change.rightPercent
            let dollarsToBuyEther = pref.spare_change_accrued_percent_to_invest * change.leftPercent
            
            let firstCurrencyToBuyInDollars = pref.spare_change_accrued_percent_to_invest * change.rightPercent
            let secondCurrencyToBuyInDollars = pref.spare_change_accrued_percent_to_invest * change.leftPercent
            if (firstCurrencyToBuyInDollars < 3 && secondCurrencyToBuyInDollars < 3) && testing == false{
                HelperFunctions.showToast(withString: "Minimum amount required to buy any cryptocurrency is $3. Kindly review!", onViewController: self)
            }else{
                //self.requestServerToBuy(mobile_secret: self.m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, dollars: dollars)
                let popUpView: PopUpViewBuyNowSelector = PopUpViewBuyNowSelector.storyboardInstance() as PopUpViewBuyNowSelector
                // put the vars for showing the view
                popUpView.dollars = dollars
                popUpView.btcToBuyValueInDollars = dollarsToBuyBtc
                popUpView.etherToBuyValueInDollars = dollarsToBuyEther
                
                popUpView.firstCurrency = firstCoin
                popUpView.secondCurrency = secondCoin
                popUpView.firstCurrencyValueInDollars = firstCurrencyToBuyInDollars
                popUpView.secondCurrencyValueInDollars = secondCurrencyToBuyInDollars
                
                // Setting the transition settings
                popUpView.modalPresentationStyle = .overCurrentContext
                popUpView.modalTransitionStyle = .crossDissolve
                self.present(popUpView, animated: true, completion: nil)
            }
        } else{
            let alert = UIAlertController(title: "Payment Configuration Issue", message: "We found no Coinbase payment methods, you will not be able to buy cryptocurrency", preferredStyle: UIAlertControllerStyle.alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                
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
}

extension ManageChangeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return currentTransactionType == .unInvested ? handler.unInvestedTrans.count : handler.investedTrans.count
        }
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ManageChangeChartCell
                cell.bind()
                cell.buyButtonHandler = { [weak self]() in
                    self?.buyNow()
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ManageChangeSegmentCell
                cell.segmentedControl.selectedSegmentIndex = (currentTransactionType == .unInvested) ? 0 : 1
                cell.valueChanged = { [weak self] (index)-> Void in
                    self?.currentTransactionType = index == 0 ? .unInvested : .invested
                    self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as ManageChangeHistoryCell
            let transaction = currentTransactionType == .unInvested ? handler.unInvestedTrans[indexPath.row] : handler.investedTrans[indexPath.row]
            cell.bind(transaction: transaction)
            return cell
        }
        
        return UITableViewCell()
    }
}
