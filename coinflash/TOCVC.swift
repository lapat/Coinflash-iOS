//
//  TOCVC.swift
//  coinflash
//
//  Created by Tallal Javed on 10/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

class TOCVC: UIViewController, MainStoryboardInstance {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // set the webkit view
        let htmlFile = Bundle.main.path(forResource: "TOC", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: nil)
        
        self.acceptButton.layer.cornerRadius = 16
    }
    
    @IBAction func didTapOnAcceptTOCButton(sende: UIButton){
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : user_mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : user_mobile_access_token,
            "accept_tos": "true"
        ]
        showHUD()
        Alamofire.request("https://coinflashapp.com/coinflashuser7/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseData { response in
            hideHUD()
            switch response.result {
            case .success(_):
                
                HelperFunctions.userAcceptedTOC()
                AppDelegate.checkOnboardStatus()
            case .failure(_):
                self.showAlert(title: "Error", message: "Network error. Please try again")
            }
        }
    }

}
