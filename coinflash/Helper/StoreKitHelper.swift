//
//  StoreKitHelper.swift
//  coinflash
//
//  Created by Tallal Javed on 11/23/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

enum SubscriptionState: Int{
    case expired = 1
    case valid = 2
    case notPurchased = 3
    case managedOnWebsite = 4
}

class StoreKitHelper: NSObject {
    static let sharedInstance = StoreKitHelper()
    var monthlySubscriptionState: SubscriptionState = .notPurchased
    var monthlySubscriptionExpiryDate: Date?
    let monthlySubscriptionProductID = "monthly_subscription_1dollar"
    var monthlySubscriptionProductInfo: SKProduct? = nil
    var localReciept: Data!
    
    private override init() {
        super.init()
    }
    
    /// Restore pruchases
    func restorePreviousPurchases(completionClosure: @escaping ()->Void, failureClosure: @escaping ()-> Void, noPurchaseClosure: @escaping ()-> Void){
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
             //   print("Restore Failed: \(results.restoreFailedPurchases)")
                failureClosure()
            }
            else if results.restoredPurchases.count > 0 {
             //   print("Restore Success: \(results.restoredPurchases)")
             //   print(results)
                self.validateReceiptWithCompletionHandler {
                    if self.monthlySubscriptionState == .valid{
                        completionClosure()
                    }else{
                        noPurchaseClosure()
                    }
                }
            }
            else {
              //  print("Nothing to Restore")
                noPurchaseClosure()
            }
        }
    }
    
    /// Sends back locally saved reciept data
    func getReceiptForCurrentUser() -> NSString{
        let receipt = SwiftyStoreKit.localReceiptData
        return receipt?.base64EncodedString(options: []) as! NSString
    }
    
    /// Tells if the user has a valid monthly subscription or not
    func userHasValidMonthlySubscription() -> Bool{
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                self.localReciept = receiptData
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
        //print(receiptData)
        
      //  print(receiptData?.base64EncodedString(options: []))
        if monthlySubscriptionExpiryDate != nil && localReciept != nil{
            if monthlySubscriptionExpiryDate! > Date(){
                return true
            }else{
                if self.monthlySubscriptionState == .managedOnWebsite{
                    return true
                }else{
                    return false
                }
            }
        }
        return false
    }
    
    /// load subscription options
    func loadSubscriptionOptions(completionClosure: @escaping (_ product: SKProduct)->Void, failureClosure: @escaping (_ error: Error)-> Void){
        if monthlySubscriptionProductInfo != nil{
            completionClosure(monthlySubscriptionProductInfo!)
            return
        }
        SwiftyStoreKit.retrieveProductsInfo([monthlySubscriptionProductID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
             //   print("Product: \(product.localizedDescription), price: \(priceString)")
                self.monthlySubscriptionProductInfo = product
                completionClosure(product)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                //return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
            }
            else {
             //   print("Error: \(result.error)")
                failureClosure(result.error!)
            }
        }
    }
    
    /// This will buy the monthly subscription
    func buyMonthlySubscriptionForUser(completionClosure: @escaping ()-> Void, failureClosure: @escaping (SKError!)-> Void){
        //if monthlySubscriptionProductInfo == nil{
        //    self.loadSubscriptionOptions(completionClosure: { (product) in
        //
        //    }, failureClosure: { (error) in
        //        return
        //    })
       // }
        
        SwiftyStoreKit.purchaseProduct(monthlySubscriptionProductInfo!) { (result) in
            switch result {
            case .success(let purchase):
              //  print("Purchase Success: \(purchase.productId)")
                self.validateReceiptForSubscription()
                completionClosure()
            case .error(let error):
                failureClosure(error)
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                    print(error.localizedDescription)
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
    }
    
    /// Verify the reciept with completion closures
    func validateReceiptWithCompletionHandler(completionHandler: @escaping ()-> Void){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "3e65ea31eaba4acb8a09f3d1da956550")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: "monthly_subscription_1dollar",
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                 //   print("Product is valid until \(expiryDate)")
                    self.monthlySubscriptionState = .valid
                    self.monthlySubscriptionExpiryDate = expiryDate
                case .expired(let expiryDate, let receiptItems):
                 //   print("Product is expired since \(expiryDate)")
                    self.monthlySubscriptionState = .expired
                    self.monthlySubscriptionExpiryDate = expiryDate
                case .notPurchased:
                  ///  print("The user has never purchased this product")
                    self.monthlySubscriptionState = .notPurchased
                    self.monthlySubscriptionExpiryDate = nil
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
            completionHandler()
            HelperFunctions.saveNSUserDefaults()
        }
    }
    
    /// Verify the receipt for subscription
    func validateReceiptForSubscription(){
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "3e65ea31eaba4acb8a09f3d1da956550")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: "monthly_subscription_1dollar",
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let expiryDate, let receiptItems):
                 //   print("Product is valid until \(expiryDate)")
                    self.monthlySubscriptionState = .valid
                    self.monthlySubscriptionExpiryDate = expiryDate
                case .expired(let expiryDate, let receiptItems):
                  //  print("Product is expired since \(expiryDate)")
                    self.monthlySubscriptionState = .expired
                    self.monthlySubscriptionExpiryDate = expiryDate
                case .notPurchased:
                  //  print("The user has never purchased this product")
                    self.monthlySubscriptionState = .notPurchased
                    self.monthlySubscriptionExpiryDate = nil
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
            HelperFunctions.saveNSUserDefaults()
        }
    }
}
