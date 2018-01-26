//
//  User.swift
//  coinflash
//
//  Created by Tallal Javed on 25/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class User: NSObject {
    // Properties
    var firstName = "", secondName = "", lastName = "", email: String = ""
    /// Keeps User profile pucture url. Could have been fetched from coinflashServer, gmail or fb
    var profilePicURL: URL!
    /// 1 = fb user , 2 = google user
    private var userType: Int = 1
    private var fbToken : AccessToken!
    private var googlAuthUser: GIDGoogleUser!
    
    static var mainUser = User()
    
    override init() {
        super.init()
    }
    
    //MARK: - Facebook
    /// Sets the fb login info from fb login result object - Seriously fb why no prefix in object names?????
    convenience init(setFromFBLogin fbResult: LoginResult){
        self.init()
        switch fbResult{
        case .cancelled:
            break
        case .failed(let error):
            print(error)
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let _ = grantedPermissions
            let _ = declinedPermissions
            self.parseFBToken(token: token)
            userType = 1
        }
    }
    
    func parseFBToken(token: AccessToken){
        self.fbToken = token
        let pic = String(format: "https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", token.userId!)
        profilePicURL = URL(string: pic)
    }
    
    //MARK:- Google
    /// Sets the user object from google user login info
    convenience init(setFromGoogleLogin gUser: GIDGoogleUser){
        self.init()
        self.googlAuthUser = gUser
        userType = 2
    }
    
    
    //MARK: - General
    
    /// Checks if user is a fb or google user and with respect to that logs the user out
    func logOutUser(){
        
    }
}
