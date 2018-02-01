//
//  CreatCoinbaseAccountVC.swift
//  coinflash
//
//  Created by Tabish Manzoor on 2/1/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation


class CreatCoinbaseAccountVC: UIViewController,UIWebViewDelegate{
    
     @IBOutlet weak var WebView: UIWebView?
    override func viewDidLoad() {
        WebView?.delegate = self
        //1. Load web site into my web view
        let myURL = URL(string: "https://www.coinbase.com/join/5924d7298fb60a02816ccc08")
        let myURLRequest:URLRequest = URLRequest(url: myURL!)
        WebView?.loadRequest(myURLRequest)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func didTapOnBackButton(sender: UIButton){
        self.dismiss(animated: true)
    }
    func webViewDidStartLoad(_ webView: UIWebView)
    {
        
    }
    func webViewDidFinishLoad(_ webView: UIWebView)
    {
        
    }
    
    
}
