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
    
    override func viewDidLoad() {
        SideMenuManager.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.menuDismissOnPush = true
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuParallaxStrength = 3
        self.requestCoinFlashFeatchccTransations(mobile_secret: "8dkkaiei20kdjkwoeo29ddkskalw82asD!", user_id_mobile: "15", mobile_access_token: "478724f8bca94e9887fb731d229e2d")
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
    
}
