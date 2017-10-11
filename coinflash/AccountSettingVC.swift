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

class AccountSettingsVC: UIViewController, UITableViewDataSource{
    @IBOutlet weak var bankTable: UITableView!
    @IBOutlet weak var coinbaseLinkedLabel: UILabel!
    
    override func viewDidLoad() {
        
        let nc =  NotificationCenter.default
        nc.addObserver(self, selector: #selector(viewDidEnterForground(notificaiton:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if coinbaseInfoObject.loggedIn == true{
            coinbaseLinkedLabel.text = "Coinbase Linked"
        }else{
            coinbaseLinkedLabel.text = "Coinbase Not Linked"
        }
    }
    
    func viewDidEnterForground(notificaiton: NSNotification){
        if (UIApplication.shared.delegate as! AppDelegate).processingBacklink == true{
            SVProgressHUD.show()
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                SVProgressHUD.dismiss()
                if coinbaseInfoObject.loggedIn == true{
                    self.coinbaseLinkedLabel.text = "Coinbase Linked"
                }else{
                    self.coinbaseLinkedLabel.text = "Coinbase Not Linked"
                }
                (UIApplication.shared.delegate as! AppDelegate).processingBacklink = false
            })
        }else{
            if coinbaseInfoObject.loggedIn == true{
                coinbaseLinkedLabel.text = "Coinbase Linked"
            }else{
                coinbaseLinkedLabel.text = "Coinbase Not Linked"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.row == 0{
            cell = tableView.dequeueReusableCell(withIdentifier: "normalCell")
        }
        else{
            cell = tableView.dequeueReusableCell(withIdentifier: "disabledCell")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    @IBAction func didTapOnAddCoinbaseButton(sender: UIButton){
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = true
        CoinbaseOAuth.startAuthentication(withClientId: "2e9035f26ec0c4bda426ffbff1f2bb800c88cec0a2f8322b85e3edd07fa2085d", scope: "wallet:buys:create", redirectUri: "com.coinbasepermittedcoinflash.apps.coinflash-1234567://coinbase-oauth", meta: nil)
    }
    
    // MARK: - API
    func requestCoinbaseLinkAPIRequest(){
        
    }
}
