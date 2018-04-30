//
//  LinkCoinbaseViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import SafariServices
import SVProgressHUD
import Alamofire

class LinkCoinbaseViewController: UIViewController, AuthenStoryboardInstance {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(coinBaseAuthenticationCompleted(withNotification:)), name: NSNotification.Name.onCoinbaseLoginCompletion, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func createButtonPressed(_ sender: Any) {
        let urlString = "https://www.coinbase.com/join/5924d7298fb60a02816ccc08"
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func linkButtonPressed(_ sender: Any) {
        startLinkingCoinbase()
    }
    
    fileprivate func goToBankLinkingPage() {
        let vc = LinkCardStartViewController.storyboardInstance() as LinkCardStartViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func startLinkingCoinbase() {
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = true
        CoinbaseOAuth.startAuthentication(withClientId: "723e663bdd30aac0f9641160de28ce520e1a065853febbd9a9c983569753bcf3", scope: "wallet:user:email,wallet:user:read,wallet:buys:create,wallet:buys:read,wallet:payment-methods:read,wallet:accounts:read,wallet:addresses:read,wallet:transactions:send,wallet:transactions:send:bypass-2fa,wallet:addresses:create", redirectUri: "com.coinbasepermittedcoinflash.apps.coinflash-12345678://coinbase-oauth", meta: ["send_limit_amount": "5.00", " send_limit_currency": "USD", "send_limit_period": "week"])
    }
    
    func coinBaseAuthenticationCompleted(withNotification notificaion: NSNotification){
        SVProgressHUD.dismiss()
        UIApplication.shared.endIgnoringInteractionEvents()
        if HelperFunctions.isCoinbaseLoggedIn() == true {
            //self.coinbaseLinkedLabel.text = "Coinbase Linked"
            //self.DlinkCoinBase.isHidden = false
            //self.addCoinbaseButton.isHidden = true
            self.requestCoinbaseLinkAPIRequest()
        } else{
            
        }
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = false
    }
    
    // MARK: - API
    func requestCoinbaseLinkAPIRequest(){
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token,
                                     "code": coinbaseInfoObject.accessToken, "redirect_url": "com.coinbasepermittedcoinflash.apps.coinflash-12345678://coinbase-oauth", "coinbase_refresh_access_token": coinbaseInfoObject.refreshToken]
        SVProgressHUD.show(withStatus: "Linking Coinbase")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)auththirdparty3/", method: HTTPMethod.post, parameters: parameter)
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    HelperFunctions.manageCoinBaseLinking()
                    self.goToBankLinkingPage()
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
        }
    }
}
