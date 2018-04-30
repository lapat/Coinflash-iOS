//
//  LinkCardStartViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import LinkKit
import SVProgressHUD
import Alamofire

class LinkCardStartViewController: UIViewController, AuthenStoryboardInstance {

    @IBOutlet weak var skipButton: UIButton!
    
    var m_mobile_secret = user_mobile_secret!
    var m_user_id = user_id_mobile!
    var m_access_token = user_mobile_access_token!
    var plaid_public_token : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func linkCreditCardButtonPressed(_ sender: Any) {
        presentPlaidLinkWithSharedConfiguration()
    }
    
    fileprivate func goToAllDoneScreen() {
        let vc = LinkAllDoneViewController.storyboardInstance() as LinkAllDoneViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentPlaidLinkWithSharedConfiguration() {
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(delegate: linkViewDelegate as PLKPlaidLinkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    }
    
    // MARK: Plaid Link setup with custom configuration
    func presentPlaidLinkWithCustomConfiguration() {
        let linkConfiguration = PLKConfiguration(key: "93bf429075d0e7ff0fc28750127c45", env: .sandbox, product: .auth)
        linkConfiguration.clientName = "Link Demo"
        let linkViewDelegate = self
        let linkViewController = PLKPlaidLinkViewController(configuration: linkConfiguration, delegate: linkViewDelegate as PLKPlaidLinkViewDelegate)
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            linkViewController.modalPresentationStyle = .formSheet;
        }
        present(linkViewController, animated: true)
    }
    
    
    
    func LinkPlaid(mobile_secret: String,user_id_mobile: String,mobile_access_token: String,public_token :String){
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "public_token" : public_token
            
        ]
        SVProgressHUD.show()
        
        Alamofire.request("https://coinflashapp.com/auththirdparty3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            
            let data = response.result.value as? NSDictionary
            
            let PLD = data?.value(forKey: "plaid_authorization_success")
            let AA = data?.value(forKey: "already_authorized")
            
            //let data = response.result.value as! [String: String]
            if PLD != nil
            {
                SVProgressHUD.dismiss()
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
                HelperFunctions.managePlaidLinked()
                
                self.goToAllDoneScreen()
            }
            else if AA != nil{
                SVProgressHUD.dismiss()
                HelperFunctions.SaveBankInfo(m_token_id: self.plaid_public_token, m_logged_in: "false") // was true
                self.goToAllDoneScreen()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.presentAlertViewWithTitle("Bank Account Link", message: "Account Link Fail : Retry")
                
            }
            // Loading the data in the Table
        }
    }
    
    func presentAlertViewWithTitle(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func handleSuccessWithToken(_ publicToken: String, metadata: [String : Any]?) {
        self.plaid_public_token = publicToken
        LinkPlaid(mobile_secret: m_mobile_secret, user_id_mobile: m_user_id, mobile_access_token: m_access_token, public_token: publicToken)
        
        
    }
    
    func handleError(_ error: Error, metadata: [String : Any]?) {
        presentAlertViewWithTitle("Failure", message: "error: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
    }
    
    func handleExitWithMetadata(_ metadata: [String : Any]?) {
        presentAlertViewWithTitle("Exit", message: "metadata: \(metadata ?? [:])")
    }
}

extension LinkCardStartViewController : PLKPlaidLinkViewDelegate
{
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didSucceedWithPublicToken publicToken: String, metadata: [String : Any]?) {
        dismiss(animated: true) {
            NSLog("Successfully linked account!\npublicToken: \(publicToken)\nmetadata: \(metadata ?? [:])")
            self.handleSuccessWithToken(publicToken, metadata: metadata)
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didExitWithError error: Error?, metadata: [String : Any]?) {
        dismiss(animated: true) {
            if let error = error {
                NSLog("Failed to link account due to: \(error.localizedDescription)\nmetadata: \(metadata ?? [:])")
            }
            else {
                NSLog("Plaid link exited with metadata: \(metadata ?? [:])")
            }
        }
    }
    
    func linkViewController(_ linkViewController: PLKPlaidLinkViewController, didHandleEvent event: String, metadata: [String : Any]?) {
        NSLog("Link event: \(event)\nmetadata: \(metadata)")
    }
}
