//
//  MainViewController.swift
//  coinflash
//
//  Created by TJ on 9/26/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit

class BuyPageController: UIViewController, UITableViewDataSource{
    @IBOutlet weak var btcBtn: UIButton?
    @IBOutlet weak var btcEth: UIButton?
    @IBOutlet weak var LabelCoin: UILabel?
    @IBOutlet weak var LabelCurrency: UILabel?
    @IBOutlet weak var LabelGroth: UILabel?
    @IBOutlet weak var LabelType: UILabel?
    @IBOutlet weak var boundryCricleImage: UIImageView?
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    @IBAction func changThemeToEther(for button: UIButton){
        btcBtn?.isEnabled  = true
        btcEth?.isEnabled  = false
        LabelCoin?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 110/255, green: 176/255, blue: 56/255, alpha: 1)
        boundryCricleImage?.image = UIImage(named: "circleGreen")
    }
    @IBAction func changThemeToBitCoin(for button: UIButton){
        btcBtn?.isEnabled  = false
        btcEth?.isEnabled  = true
        LabelCoin?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelCurrency?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelGroth?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        LabelType?.textColor = UIColor(red: 56/255, green: 113/255, blue: 177/255, alpha: 1)
        
        boundryCricleImage?.image = UIImage(named: "circleBlue")
    }
    
    
}
