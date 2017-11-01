//
//  TOCVC.swift
//  coinflash
//
//  Created by Tallal Javed on 10/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import WebKit

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
        self.performSegue(withIdentifier: "mainPageSegue", sender: self)
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
