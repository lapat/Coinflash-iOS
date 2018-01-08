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
import Alamofire
import SwiftyJSON

class InAppPurchaseVC: UIViewController {
    
    @IBOutlet var purchaseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // add border to the buy button
        self.purchaseButton.layer.borderWidth = 1.0
        self.purchaseButton.layer.cornerRadius = 5.0
        self.purchaseButton.layer.borderColor = UIColor(red: 8/255.0, green: 79/255.0, blue: 159/255.0, alpha: 1.0).cgColor
        
        self.fetchSubscriptionOptions()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchSubscriptionOptions(){
        // Get localized pricing
        SVProgressHUD.show(withStatus: "Loading Info")
        StoreKitHelper.sharedInstance.loadSubscriptionOptions(completionClosure: { (product) in
            SVProgressHUD.dismiss()
          //  print(product.localizedPrice)
            let priceString = product.localizedPrice!
            self.purchaseButton.setTitle("\(priceString)", for: UIControlState.normal)
        }) { (error) in
            SVProgressHUD.dismiss()
            let alert = UIAlertController(title: "Error", message: "Network error, kindly retry to load subscription info", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (action) in
                self.fetchSubscriptionOptions()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                self.didTapOnBackButton(sender: UIButton())
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func sendServerInAppPurchaseInfo(receipt: NSString){
        //SVProgressHUD.show(withStatus: "Finalizing Purchase")
        let parameter = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token, "in_app_receipt": receipt] as [String : Any]
      //  print("=-------- START -------=")
      //  print(receipt)
      //  print("=-------- END -------=")
        Alamofire.request("\(baseUrl)coinflashuser4/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    SVProgressHUD.dismiss()
                 //   print(value)
                    let alert = UIAlertController(title: "Success", message: "Subscription is now active", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{(action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                case .failure:
                //    print("failure")
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Error", message: "Check your internet connection and retry", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    
    @IBAction func didTapOnBackButton(sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapOnBuyButton(){
        SVProgressHUD.show()
        StoreKitHelper.sharedInstance.buyMonthlySubscriptionForUser(completionClosure: {
            SVProgressHUD.dismiss()
            // No need to show any alerts... apple itself manages the alerts very well
            SVProgressHUD.show(withStatus: "Updating Information")
            self.sendServerInAppPurchaseInfo(receipt: StoreKitHelper.sharedInstance.getReceiptForCurrentUser())
            
        }) { (error) in
            SVProgressHUD.dismiss()
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
        /// check if info was loaded successfully
        
        StoreKitHelper.sharedInstance.restorePreviousPurchases(completionClosure: {
            let alert = UIAlertController(title: "Success", message: "Purchases have been restored.", preferredStyle: UIAlertControllerStyle.alert)
            let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { (alert) in
                //self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
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
