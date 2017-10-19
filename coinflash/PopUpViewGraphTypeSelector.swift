//
//  PopUpViewGraphTypeSelector.swift
//  coinflash
//
//  Created by Tabish Manzoor on 10/13/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation


class PopUpViewGraphTypeSelector:UIViewController , UIGestureRecognizerDelegate{
    @IBOutlet var MainView: UIView!
    override func viewDidLoad() {
       
        super.viewDidLoad()
       
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        self.view.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
        self.showAnimate()
        

    }
    func tapped(gestureRecognizer: UITapGestureRecognizer) {
         removeAnimate()
    }
    @IBAction func ButtonTouch(_ sender: Any) {
        print("Stop")
        removeAnimate()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Option1(_ sender: AnyObject) {
        self.removeAnimate()
        GraphOptionSelected = 1
        isGraphOptionSelected = true
    }
    @IBAction func Option2(_ sender: AnyObject) {
        self.removeAnimate()
        GraphOptionSelected = 2
        isGraphOptionSelected = true
    }
    @IBAction func Option3(_ sender: AnyObject) {
        self.removeAnimate()
        GraphOptionSelected = 3
        isGraphOptionSelected = true
    }
    
    
    @IBAction func closePopUp(_ sender: AnyObject) {
        self.removeAnimate()
        //self.view.removeFromSuperview()
    }
    
    func showAnimate()
    {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    func removeAnimate()
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished)
            {
                self.view.removeFromSuperview()
            }
        });
    }
    
    
    
}
