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
        
        let a: (sig: Signal<Any?, NoError>, os: [Any]) = __sigs()
        a.sig.observeValues { (things: Any?) in
            print("work")
        }
        
        //let o1 = a.os.first! as! Signal.Observer<String, NoError>
        //let o2 = a.os[1] as! Signal.Observer<Any?, NoError>
        
        //o1.send(value: "ao")
        //o2.send(value: "ao") // Just triggers the above to print "work"
        //o2.send(value: "ao")
        
    }
    
    func __sigs() -> (sig: Signal<Any?, NoError>, os: [Any]) {
        let (s1, o1) = Signal<String, NoError>.pipe() // In actual code I have 10+ signals in each method
        let (s2, o2) = Signal<Any?, NoError>.pipe()
        
        let (s, o) = Signal<Any?, NoError>.pipe()
        Signal.combineLatest(s1, s2).observeValues{ _ in
            o.send(value: "anything") // gross hack
        }
        
        return (sig: s, os: [o1, o2])
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
