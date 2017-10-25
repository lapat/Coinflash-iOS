//
//  HelperFunctions.swift
//  coinflash
//
//  Created by Tallal Javed on 10/8/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import Toast_Swift

extension Notification.Name {
    
    static let onCoinbaseLoginCompletion = Notification.Name("onCoinbaseLoginCompletion")
    static let onSuccessfulPurchaseOfCoins = Notification.Name("onSuccessfulPurchaseOfCoins")
}

class HelperFunctions: NSObject {

    static func saveLoginInfo(user: GIDGoogleUser, userIdMobile: String!, mobileAccessToken: String!, onboardStatus: String!){
        googleUser = user
        user_mobile_access_token = mobileAccessToken
        user_id_mobile = userIdMobile
        user_isLoggedIn = true
        let status = Int(onboardStatus)
        if status == 0{
            user_onboard_status = OnBoardStatus.didNotAcceptTOC
            coinbaseInfoObject.loggedIn = false
            plaidInfoObject.loggedIn = false
        }
        if status == 1{
            user_onboard_status = OnBoardStatus.agreedTOCNoPlaidOrCoinbase
            coinbaseInfoObject.loggedIn = false
            plaidInfoObject.loggedIn = false
        }
        if status == 2{
            user_onboard_status = OnBoardStatus.linkedPlaidButNoCoinbase
            coinbaseInfoObject.loggedIn = false
            plaidInfoObject.loggedIn = true
        }
        if status == 3{
            user_onboard_status = OnBoardStatus.linkedCoinbaseButNoPlaid
            coinbaseInfoObject.loggedIn = true
            plaidInfoObject.loggedIn = false
        }
        if status == 4{
            user_onboard_status = OnBoardStatus.linkedPlaidAndCoinbase
            coinbaseInfoObject.loggedIn = true
            plaidInfoObject.loggedIn = true
        }
        self.saveNSUserDefaults()
    }
    
    static func updateVariablesForUserLoggingOut(){
        googleUser = nil
        user_mobile_access_token = ""
        user_id_mobile = ""
        user_isLoggedIn = false
        GIDSignIn.sharedInstance().signOut()
        //self.saveNSUserDefaults()
    }
    
    static func userAcceptedTOC(){
        if OnBoardStatus.didNotAcceptTOC == user_onboard_status{
           user_onboard_status =  OnBoardStatus.agreedTOCNoPlaidOrCoinbase
        }
    }
    
    static func isTOCAccepted() -> Bool{
        if user_onboard_status == OnBoardStatus.didNotAcceptTOC{
            return false
        }else{
            return true
        }
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
        self.manageCoinBaseLinking()
        print("number \(coinbaseInfoObject.expiresIn)")
    }
    
    static func isCoinbaseLoggedIn() -> Bool{
        if user_onboard_status == OnBoardStatus.linkedPlaidAndCoinbase || user_onboard_status == OnBoardStatus.linkedCoinbaseButNoPlaid{
            return true
        }else{
            return false
        }
    }
    
    static func manageCoinbaseDelinking(){
        if user_onboard_status == OnBoardStatus.linkedCoinbaseButNoPlaid{
            user_onboard_status = OnBoardStatus.agreedTOCNoPlaidOrCoinbase
        }
        if user_onboard_status == OnBoardStatus.linkedPlaidAndCoinbase{
            user_onboard_status = OnBoardStatus.linkedPlaidButNoCoinbase
        }
    }
    
    static func manageCoinBaseLinking(){
        if user_onboard_status == OnBoardStatus.agreedTOCNoPlaidOrCoinbase{
            user_onboard_status = OnBoardStatus.linkedCoinbaseButNoPlaid
        }
        if user_onboard_status == OnBoardStatus.linkedPlaidButNoCoinbase{
            user_onboard_status = OnBoardStatus.linkedPlaidAndCoinbase
        }
    }
    
    // MARK: - Defaults
    // saves the ns user defaults
    static func saveNSUserDefaults(){
        UserDefaults.standard.set(user_id_token, forKey: "user_id_token")
        UserDefaults.standard.set(user_id_mobile, forKey: "user_id_mobile")
        UserDefaults.standard.set(user_mobile_access_token, forKey: "user_mobile_access_token")
        UserDefaults.standard.set(user_isLoggedIn, forKey: "user_isLoggedIn")
        
        // save google user
        //let googleData  = NSKeyedArchiver.archivedData(withRootObject: googleUser)
       // UserDefaults.standard.set(googleData, forKey: "googleUser")
        /*
        UserDefaults.standard.set(globalSettings, forKey: "globalSettings")
        UserDefaults.standard.set(cctransaction_global, forKey: "cctransaction_global")
        UserDefaults.standard.set(coinbaseInfoObject, forKey: "coinbaseInfoObject")
         */
    }
    
    // loads the nsuser defaults and save them to the vars
    static func loadNSUserDefaults(){
        user_id_token = UserDefaults.standard.value(forKey: "user_id_token") as? String
        user_id_mobile = UserDefaults.standard.value(forKey: "user_id_mobile") as? String
        user_mobile_access_token = UserDefaults.standard.value(forKey: "user_mobile_access_token") as? String
        user_isLoggedIn = UserDefaults.standard.value(forKey: "user_isLoggedIn") as? Bool
        
        /*
        if let loadedData = UserDefaults.standard.value(forKey: "googleUser"){
            if let user = NSKeyedUnarchiver.unarchiveObject(with: loadedData as! Data){
                googleUser = user as! GIDGoogleUser
            }
        }
        
        if UserDefaults.standard.value(forKey: "globalSettings") != nil{
            globalSettings = UserDefaults.standard.value(forKey: "globalSettings") as! GlobalSettings
        }
        cctransaction_global = UserDefaults.standard.value(forKey: "cctransaction_global") as? TRansactionInfo
        if UserDefaults.standard.value(forKey: "coinbaseInfoObject") as? CoinbaseInfo != nil{
            coinbaseInfoObject = UserDefaults.standard.value(forKey: "coinbaseInfoObject") as! CoinbaseInfo
        }
         */
    }
    static func SaveBankInfo(m_token_id : String , m_logged_in : String){
        plaidInfoObject.accessToken = m_token_id
        if m_logged_in == "true"{
            plaidInfoObject.loggedIn = true
        }else{
            plaidInfoObject.loggedIn = false
        }
        UserDefaults.standard.set(plaidInfoObject.accessToken, forKey: "bank_token_id")
        UserDefaults.standard.set(plaidInfoObject.loggedIn, forKey: "bank_is_locked_in")
        
        
    }
    static func LoadBankInfo(){
        plaidInfoObject.accessToken = UserDefaults.standard.value(forKey: "bank_token_id") as? String
        plaidInfoObject.loggedIn = UserDefaults.standard.value(forKey: "bank_is_locked_in") as? Bool
        
    }
    
    
    //MARK: - Toast
    static func showToast(withString string: String, onViewController viewController: UIViewController){
        
        viewController.view.makeToast(string, duration: 3, position: .center)
    }
    
    //MARK:- Coinbase and Plaid Integerations
    static func isPlaidLoggedIn() -> Bool{
        if user_onboard_status == OnBoardStatus.linkedPlaidAndCoinbase || user_onboard_status == OnBoardStatus.linkedPlaidButNoCoinbase{
            return true
        }else{
            return false
        }
    }
    
}

extension UIColor {
    static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor, intensity2: CGFloat = 0.5) -> UIColor {
        let total = intensity1 + intensity2
        let l1 = intensity1/total
        let l2 = intensity2/total
        guard l1 > 0 else { return color2}
        guard l2 > 0 else { return color1}
        var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return UIColor(red: l1*r1 + l2*r2, green: l1*g1 + l2*g2, blue: l1*b1 + l2*b2, alpha: l1*a1 + l2*a2)
    }
}

