//
//  LinkAccountStartViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit

class LinkAccountStartViewController: UIViewController, AuthenStoryboardInstance {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func getStartedButtonPressed(_ sender: Any) {
        let vc = CoinbaseLoginViewController.storyboardInstance() as CoinbaseLoginViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    

}
