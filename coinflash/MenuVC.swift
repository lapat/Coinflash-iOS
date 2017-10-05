//
//  MenuVC.swift
//  coinflash
//
//  Created by Tabish Manzoor on 10/4/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import ReactiveSwift
import Result

class MenuVC: UIViewController {

    // creating a reactiveswift channel
    var sp : SignalProducer<String, NoError>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // View Navigation:
    @IBAction func didTapOnSettings(sender: UIGestureRecognizer){
        sendSignal(withMessage: "Account Settings")
    }
    
    func sendSignal(withMessage message: String)  {
        print(message)
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
