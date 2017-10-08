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

class AccountSettingsVC: UIViewController, UITableViewDataSource{
    @IBOutlet weak var bankTable: UITableView!
    
    
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
        CoinbaseOAuth.startAuthentication(withClientId: "2e9035f26ec0c4bda426ffbff1f2bb800c88cec0a2f8322b85e3edd07fa2085d", scope: "wallet:buys:create", redirectUri: "com.coinbasepermittedcoinflash.apps.coinflash-1234567://coinbase-oauth", meta: nil)
    }
    
}
