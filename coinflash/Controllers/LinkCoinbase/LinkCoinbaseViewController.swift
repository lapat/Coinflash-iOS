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
        print("goToBankLinkingPage")
        if (!HelperFunctions.isPlaidLoggedIn()){
          let vc = LinkCardStartViewController.storyboardInstance() as LinkCardStartViewController
          navigationController?.pushViewController(vc, animated: true)
        }else{
            guard let app = UIApplication.shared.delegate as? AppDelegate else {
            return
            }
            app.goToMainPage()
        }
    }
        
    
    fileprivate func startLinkingCoinbase() {
        (UIApplication.shared.delegate as! AppDelegate).processingBacklink = true
        CoinbaseOAuth.startAuthentication(withClientId: "fb8d49906184ea0934d6d60c05b2f336f94f93b30bf9708a1a77d0f7c7e10fc5", scope: "wallet:user:email,wallet:user:read,wallet:buys:create,wallet:buys:read,wallet:payment-methods:read,wallet:accounts:read,wallet:addresses:read,wallet:transactions:send,wallet:addresses:create", redirectUri: "com.coinbasepermittedcoinflash1.apps.coinflash-999://coinbase-oauth", meta: ["send_limit_amount": "1.00", " send_limit_currency": "USD", "send_limit_period": "week"])
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
        let mobileSecret = String(describing: user_mobile_secret!)
        print("user_id_mobile")
        print(user_id_mobile)
        print("user_mobile_secret")
        print(user_mobile_secret)
        print("coinbaseInfoObject.accessToken")
        print(coinbaseInfoObject.accessToken)
        print("coinbaseInfoObject.refreshToken")
        print(coinbaseInfoObject.refreshToken)
        print("user_mobile_access_token")
        print(user_mobile_access_token)
        let parameter: Parameters = ["mobile_secret": mobileSecret, "user_id_mobile": String(describing: user_id_mobile!), "mobile_access_token": String(describing: user_mobile_access_token!),
                                     "code": String(describing: coinbaseInfoObject.accessToken!), "redirect_url": "com.coinbasepermittedcoinflash1.apps.coinflash-999://coinbase-oauth", "coinbase_refresh_access_token": String(describing: coinbaseInfoObject.refreshToken!)]
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
