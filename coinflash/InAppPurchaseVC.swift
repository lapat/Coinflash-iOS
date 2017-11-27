//
//  InAppPurchaseVC.swift
//  coinflash
//
//  Created by Tallal Javed on 11/23/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

class InAppPurchaseVC: UIViewController {
    
    @IBOutlet var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // add border to the buy button
        self.purchaseButton.layer.borderWidth = 1.0
        self.purchaseButton.layer.cornerRadius = 5.0
        self.purchaseButton.layer.borderColor = UIColor(red: 8/255.0, green: 79/255.0, blue: 159/255.0, alpha: 1.0).cgColor
        
        // Get localized pricing
        SVProgressHUD.show(withStatus: "Loading Info")
        StoreKitHelper.sharedInstance.loadSubscriptionOptions(completionClosure: { (product) in
            SVProgressHUD.dismiss()
            print(product.localizedPrice)
            let priceString = product.localizedPrice!
            self.purchaseButton.setTitle("\(priceString)", for: UIControlState.normal)
            
        }) { (error) in
            SVProgressHUD.dismiss()
            print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapOnBackButton(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnBuyButton(){
        StoreKitHelper.sharedInstance.buyMonthlySubscriptionForUser(completionClosure: {
            let alert = UIAlertController(title: "Success", message: "Subscription is now active", preferredStyle: UIAlertControllerStyle.alert)
        }) { (error) in
            switch error.code {
            case .unknown: print("Unknown error. Please contact support")
            case .clientInvalid: print("Not allowed to make the payment")
            case .paymentCancelled: break
            case .paymentInvalid: print("The purchase identifier was invalid")
            case .paymentNotAllowed: print("The device is not allowed to make the payment")
            case .storeProductNotAvailable: print("The product is not available in the current storefront")
            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
            }
        }
    }
    
    @IBAction func didTapOnRestorePurchasesButton(){
        StoreKitHelper.sharedInstance.restorePreviousPurchases(completionClosure: {
            let alert = UIAlertController(title: "Success", message: "Purchases have been restored.", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alert) in
                //self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }, failureClosure: {
            let alert = UIAlertController(title: "Error", message: "Unable to restore purchase. Kindly retry.", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alert) in
                //self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }) {
            let alert = UIAlertController(title: "No Purchases", message: "You haven't made any purchases yet.", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alert) in
                //self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(okayAction)
            self.present(alert, animated: true, completion: nil)
        }
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
