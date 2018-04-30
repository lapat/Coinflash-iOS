//
//  CoinbaseLoginViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import SafariServices

class CoinbaseLoginViewController: UIViewController, AuthenStoryboardInstance {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func createAccountButtonPressed(_ sender: Any) {
        let urlString = "https://www.coinbase.com/join/5924d7298fb60a02816ccc08"
        guard let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        let vc = LinkCoinbaseViewController.storyboardInstance() as LinkCoinbaseViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
