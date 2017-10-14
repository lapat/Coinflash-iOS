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
            UIApplication.shared.beginIgnoringInteractionEvents()
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (timer) in
                SVProgressHUD.dismiss()
                UIApplication.shared.endIgnoringInteractionEvents()
                if coinbaseInfoObject.loggedIn == true{
                    self.coinbaseLinkedLabel.text = "Coinbase Linked"
                    self.requestCoinbaseLinkAPIRequest()
                }else{
                    self.coinbaseLinkedLabel.text = "Coinbase Not Linked"
                }
                (UIApplication.shared.delegate as! AppDelegate).processingBacklink = false
            })
        }else{
            if coinbaseInfoObject.loggedIn == true{
                coinbaseLinkedLabel.text = "Coinbase Linked"
                self.requestCoinbaseLinkAPIRequest()
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
        CoinbaseOAuth.startAuthentication(withClientId: "723e663bdd30aac0f9641160de28ce520e1a065853febbd9a9c983569753bcf3", scope: "wallet:buys:create", redirectUri: "com.coinbasepermittedcoinflash.apps.coinflash-12345678://coinbase-oauth", meta: nil)
    }
    
    // MARK: - API
    func requestCoinbaseLinkAPIRequest(){
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "code": coinbaseInfoObject.accessToken]
        SVProgressHUD.show(withStatus: "Linking Coinbase")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)auththirdparty3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    let data = response.result.value as! [String: Any]
                    print(data)
                    // Dismiss all views and load the login view
                    
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
