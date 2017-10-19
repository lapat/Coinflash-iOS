//
//  PopUpViewGraphTypeSelectorBuyNow.swift
//  coinflash
//
//  Created by Tabish Manzoor on 10/13/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import SideMenu
import Alamofire
import SVProgressHUD
import LinkKit
import SwiftyJSON

class PopUpViewBuyNowSelector:UIViewController , UIGestureRecognizerDelegate{
    @IBOutlet var MainView: UIView!
    @IBOutlet var etherBTCView: UIView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var etherToBuyLabel: UILabel!
    @IBOutlet var btcToBuyLabel: UILabel!
    
    var dollars: Double!
    var etherToInvest: Double!
    var etherToBuyValueInDollars: Double!
    var btcToInvest: Double!
    var btcToBuyValueInDollars: Double!
    
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    
    var m_price_right_now_eth : Double = 0.0
    var m_price_right_now_btc : Double = 0.0
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        etherBTCView.layer.borderColor = UIColor.gray.cgColor
        etherBTCView.layer.borderWidth = 1
        etherBTCView.layer.cornerRadius = 15
        
        popUpView.layer.cornerRadius = 15
    
        self.showAnimate()
        self.requestCoinFlashFeatchwallet(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token)
    }
    
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
        removeAnimate()
    }
    @IBAction func ButtonTouch(_ sender: Any) {
        print("Stop")
        self.requestServerToBuy(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, dollars: dollars)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.removeAnimate()
        //self.view.removeFromSuperview()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func requestServerToBuy(mobile_secret: String, user_id_mobile: String, mobile_access_token: String, dollars: Double){
        let parameters = ["mobile_secret": mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": mobile_access_token,
                          "dollar_amount": dollars] as [String : Any]
        SVProgressHUD.show(withStatus: "Buying coins for you!")
        Alamofire.request("\(baseUrl)coinflashbuy3/", method: HTTPMethod.post, parameters: parameters)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    print(response)
                    self.removeAnimate()
                case .failure:
                    HelperFunctions.showToast(withString: "Error connecting to server. Please retry!", onViewController: self)
                }
        }
    }
    
    func requestCoinFlashFeatchwallet(mobile_secret: String,user_id_mobile: String,mobile_access_token: String){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            ]
        SVProgressHUD.show(withStatus: "Fetching latest prices from coinbase.")
        
        Alamofire.request("https://coinflashapp.com/coinflashtransactions3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            
            let datatransation = response.result.value as! NSDictionary
            
            
            if datatransation["price_right_now_eth"] != nil{
                self.m_price_right_now_eth = datatransation.value(forKey: "price_right_now_eth") as! Double
            }
            
            if datatransation["price_right_now_btc"] != nil{
                self.m_price_right_now_btc = datatransation.value(forKey: "price_right_now_btc") as! Double
            }
            SVProgressHUD.dismiss()
            // Set the labels
            self.etherToBuyLabel.text = String(format: "%.6f ETH Worth $%.2f", self.etherToBuyValueInDollars/self.m_price_right_now_eth, self.etherToBuyValueInDollars!)
            self.btcToBuyLabel.text = String(format: "%.6f BTC Worth $%.2f",self.btcToBuyValueInDollars/self.m_price_right_now_btc, self.btcToBuyValueInDollars!)
            
        }
    }
        
        
    
    
    
    
}
