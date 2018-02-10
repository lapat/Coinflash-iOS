//
//  AppDelegate.swift
//  coinflash
//
//  Created by TJ on 9/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import SideMenu
import coinbase_official
import LinkKit
import SVProgressHUD
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var processingBacklink: Bool = false
    var mainNavController: UINavigationController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Setting up the side menu
        SideMenuManager.menuEnableSwipeGestures = true
        
        HelperFunctions.loadNSUserDefaults()
        
        // Plaid Configuration
        #if USE_CUSTOM_CONFIG
            setupPlaidWithCustomConfiguration()
        #else
            setupPlaidLinkWithSharedConfiguration()
        #endif
        
        SVProgressHUD.setDefaultMaskType(.black)
        
        /// Swfit store key
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                   // print("purchased: \(purchase)")
                }
            }
        }
        
        // set the status bar
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor(red: 171/255, green: 194/255, blue: 222/255, alpha: 1)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        HelperFunctions.saveNSUserDefaults()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        HelperFunctions.saveNSUserDefaults()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        HelperFunctions.saveNSUserDefaults()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "com.coinbasepermittedcoinflash.apps.coinflash-12345678"{
            CoinbaseOAuth.finishAuthentication(for: url, clientId: "723e663bdd30aac0f9641160de28ce520e1a065853febbd9a9c983569753bcf3", clientSecret: "c1206329ae9c879294696544da3406d83754a350c33920266279210389971278", completion: { (result, error) in
                if error != nil {
                    // Could not authenticate.
                } else {
                    // Tokens successfully obtained!
                    // Do something with them (store them, etc.)
                    if let result = result as? [String : AnyObject] {
                        if let accessToken = result["access_token"] as? String {
                            let apiClient = Coinbase(oAuthAccessToken: accessToken)
                           // print(apiClient!)
                           // print(result)
                        }
                    }
                    HelperFunctions.coinBaseSaveLoginInfo(info: result as! NSDictionary)
                    self.processingBacklink = false
                    NotificationCenter.default.post(name: .onCoinbaseLoginCompletion, object: nil)
                    // Note that you should also store 'expire_in' and refresh the token using CoinbaseOAuth.getOAuthTokensForRefreshToken() when it expires
                }
            })
        }
        
        if url.scheme == "com.googleusercontent.apps.678747170744-6o53mljo3a5q9o9avn6jvbm1r7vsjtv9"{
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        
       // print("outside if \(url.scheme)")
        return true
    }
    
    // MARK: Plaid Link setup with shared configuration from Info.plist
    func setupPlaidLinkWithSharedConfiguration() {
        // <!-- SMARTDOWN_SETUP_SHARED -->
        // With shared configuration from Info.plist
        PLKPlaidLink.setup { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }
        // <!-- SMARTDOWN_SETUP_SHARED -->
    }
    
    // MARK: Plaid Link setup with custom configuration
    func setupPlaidWithCustomConfiguration() {
        // <!-- SMARTDOWN_SETUP_CUSTOM -->
        // With custom configuration
        let linkConfiguration = PLKConfiguration(key: "93bf429075d0e7ff0fc28750127c45", env: .production, product: .transactions)
        linkConfiguration.clientName = ""
        PLKPlaidLink.setup(with: linkConfiguration) { (success, error) in
            if (success) {
                // Handle success here, e.g. by posting a notification
                NSLog("Plaid Link setup was successful")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PLDPlaidLinkSetupFinished"), object: self)
            }
            else if let error = error {
                NSLog("Unable to setup Plaid Link due to: \(error.localizedDescription)")
            }
            else {
                NSLog("Unable to setup Plaid Link")
            }
        }
        // <!-- SMARTDOWN_SETUP_CUSTOM -->
    }


}

