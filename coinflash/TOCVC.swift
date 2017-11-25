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
import SVProgressHUD

class TOCVC: UIViewController {

    @IBOutlet weak var acceptButton: UIButton!
    /// This view is used to get the dimensions of wkwebview. The webview is then drawn inside it with same frame.
    @IBOutlet weak var webViewPlaceHolder: UIView!
    /// used because before ios11 wkview was not able to be initiazed from storyboard and resulted in crash
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView = WKWebView(frame: webViewPlaceHolder.frame)
        webViewPlaceHolder.addSubview(webView)
        // set the webkit view
        let htmlFile = Bundle.main.path(forResource: "TOC", ofType: "html")
        let html = try? String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        webView.loadHTMLString(html!, baseURL: nil)
        
        self.acceptButton.layer.cornerRadius = 16
        
    }
    
    @IBAction func didTapOnAcceptTOCButton(sende: UIButton){
        HelperFunctions.userAcceptedTOC()
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : user_mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : user_mobile_access_token,
            "accept_tos" : "true"
        ]
        SVProgressHUD.show(withStatus: "Updating Values")
        
        Alamofire.request("https://coinflashapp.com/coinflashuser3/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            SVProgressHUD.dismiss()
            switch response.result{
            case .success(let value):
                self.performSegue(withIdentifier: "mainPageSegue", sender: self)
            case .failure:
                let alert = UIAlertController(title: "Error", message: "Check your network connection and retry", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
