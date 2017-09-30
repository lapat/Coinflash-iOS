//
//  ViewController.swift
//  coinflash
//
//  Created by TJ on 9/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Change status bar color
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 171/255, green: 194/255, blue: 222/255, alpha: 1)
        //statusBar.backgroundColor = UIColor.red
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

