//
//  HelperFunctions.swift
//  coinflash
//
//  Created by Tallal Javed on 10/8/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit

class HelperFunctions: NSObject {

    static func saveLoginInfo(user: GIDGoogleUser, userIdMobile: String!, mobileAccessToken: String!){
        googleUser = user
        user_mobile_access_token = mobileAccessToken
        user_id_mobile = userIdMobile
        user_isLoggedIn = true
        self.saveNSUserDefaults()
    }
    
    
    // MARK: - Coin base Helpers
    static func coinBaseSaveLoginInfo(info: NSDictionary){
        // save all the info in the coinbase struct
        print(info)
        coinbaseInfoObject.accessToken = info.value(forKey: "access_token") as! String
        coinbaseInfoObject.expiresIn = NSNumber(value: info.value(forKey: "expires_in") as! Int)
        coinbaseInfoObject.refreshToken = info.value(forKey: "refresh_token") as! String
        coinbaseInfoObject.scope = info.value(forKey: "scope") as! String
        coinbaseInfoObject.tokenType = info.value(forKey: "token_type") as! String
        coinbaseInfoObject.loggedIn = true
        print("number \(coinbaseInfoObject.expiresIn)")
    }
    
    // MARK: - Defaults
    // saves the ns user defaults
    static func saveNSUserDefaults(){
        UserDefaults.standard.set(user_id_token, forKey: "user_id_token")
        UserDefaults.standard.set(user_id_mobile, forKey: "user_id_mobile")
        UserDefaults.standard.set(user_mobile_access_token, forKey: "user_mobile_access_token")
        UserDefaults.standard.set(user_isLoggedIn, forKey: "user_isLoggedIn")
        
        // save google user
        //let data: NSData = NSData(base64Encoded: googleUser, options: nil)
        UserDefaults.standard.set(data, forKey: "googleUser")
        
        UserDefaults.standard.set(globalSettings, forKey: "globalSettings")
        UserDefaults.standard.set(cctransaction_global, forKey: "cctransaction_global")
        UserDefaults.standard.set(coinbaseInfoObject, forKey: "coinbaseInfoObject")
    }
    
    // loads the nsuser defaults and save them to the vars
    static func loadNSUserDefaults(){
        user_id_token = UserDefaults.standard.value(forKey: "user_id_token") as? String
        user_id_mobile = UserDefaults.standard.value(forKey: "user_id_mobile") as? String
        user_mobile_access_token = UserDefaults.standard.value(forKey: "user_mobile_access_token") as? String
        user_isLoggedIn = UserDefaults.standard.value(forKey: "user_isLoggedIn") as? Bool
        googleUser = UserDefaults.standard.value(forKey: "googleUser") as? GIDGoogleUser
        /*
        if UserDefaults.standard.value(forKey: "globalSettings") != nil{
            globalSettings = UserDefaults.standard.value(forKey: "globalSettings") as! GlobalSettings
        }
        cctransaction_global = UserDefaults.standard.value(forKey: "cctransaction_global") as? TRansactionInfo
        if UserDefaults.standard.value(forKey: "coinbaseInfoObject") as? CoinbaseInfo != nil{
            coinbaseInfoObject = UserDefaults.standard.value(forKey: "coinbaseInfoObject") as! CoinbaseInfo
        }
         */
    }
}
