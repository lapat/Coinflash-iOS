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
    
    
    @IBAction func InvestmentRateSlider(_ sender: Any) {
        let Rate = SliderinvestmentRateDecider?.value
        self.LabelBitcoinInvestmentRate?.text = String(format:"%.0f", Rate!) + "%"
        self.LabelEtherInvestmentRate?.text = String(format:"%.0f", (100 - Rate!)) + "%"
        
    }
    
    override func viewDidLoad() {
        SideMenuManager.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.menuDismissOnPush = true
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuParallaxStrength = 3
        self.requestCoinFlashFeatchccTransations(mobile_secret: "8dkkaiei20kdjkwoeo29ddkskalw82asD!", user_id_mobile: "15", mobile_access_token: "478724f8bca94e9887fb731d229e2d")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    
    func requestCoinFlashFeatchccTransations(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        print("working")
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : "8dkkaiei20kdjkwoeo29ddkskalw82asD!",
            "user_id_mobile" : "7481",
            "mobile_access_token" : "1bfeb051d88a45d2bc6ede6592bb44",
        ]
       Alamofire.request("https://coinflashapp.com/coinflashuser3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
        
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
                
            }
        }
       

    }
    
}
