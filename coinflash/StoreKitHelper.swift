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

class StoreKitHelper: NSObject {
    static let sharedInstance = StoreKitHelper()
    let monthlySubscriptionProductID = "monthly_subscription_1dollar"
    var monthlySubscriptionProductInfo: SKProduct? = nil
    
    private override init() {}
    
    /// Restore pruchases
    func restorePreviousPurchases(){
        
    }
    
    /// Tells if the user has a valid monthly subscription or not
    func checkIfUserHasValidMonthluSubscription() -> Bool{
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
                print("Product: \(product.localizedDescription), price: \(priceString)")
                self.monthlySubscriptionProductInfo = product
                completionClosure(product)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                //return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
                failureClosure(result.error!)
            }
        }
    }
    
    /// This will buy the monthly subscription
    func buyMonthlySubscriptionForUser(completionClosure: @escaping ()-> Void, failureClosure: @escaping (SKError!)-> Void){
        SwiftyStoreKit.purchaseProduct(monthlySubscriptionProductInfo!) { (result) in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
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
    
    /// Restore previous purchases
    func restorePreviousPurchasesForuser(){
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
}
