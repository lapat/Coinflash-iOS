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
        if url.scheme == "com.coinbasepermittedcoinflash.apps.coinflash-1234567"{
            CoinbaseOAuth.finishAuthentication(for: url, clientId: "2e9035f26ec0c4bda426ffbff1f2bb800c88cec0a2f8322b85e3edd07fa2085d", clientSecret: "e4bdb576e075dbf838f3029672fda7a90b4aae4a05f2dbce2602212ada50e9ca", completion: { (result, error) in
                if error != nil {
                    // Could not authenticate.
                } else {
                    // Tokens successfully obtained!
                    // Do something with them (store them, etc.)
                    if let result = result as? [String : AnyObject] {
                        if let accessToken = result["access_token"] as? String {
                            let apiClient = Coinbase(oAuthAccessToken: accessToken)
                            print(apiClient!)
                            print(result)
                        }
                    }
                    HelperFunctions.coinBaseSaveLoginInfo(info: result as! NSDictionary)
                    self.processingBacklink = false
                    // Note that you should also store 'expire_in' and refresh the token using CoinbaseOAuth.getOAuthTokensForRefreshToken() when it expires
                }
            })
        }
        
        print("outside if \(url.scheme)")
        return true
    }


}

