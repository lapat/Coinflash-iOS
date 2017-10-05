//
//  AccountSettingVC.swift
//  coinflash
//
//  Created by tallal on 9/30/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit

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
    
}
