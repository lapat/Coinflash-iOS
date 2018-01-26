//
//  User.swift
//  coinflash
//
//  Created by Tallal Javed on 25/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import FacebookLogin

class User: NSObject {
    // Properties
    var firstName = "", secondName = "", lastName = "", email: String = ""
    /// Keeps User profile pucture url. Could have been fetched from coinflashServer, gmail or fb
    var profilePicURL: NSURL!
    /// 1 = fb user , 2 = google user
    private var userType: Int = 1
    private var fbAuthenticationToken : String!
    private var googlAuthenitcationToken: String!
    
    static var mainUser = User()
    
    override init() {
        super.init()
    }
    
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
            self.fbAuthenticationToken = token.authenticationToken
        }
    }
    
    /// Sets the user object from google user login info
    convenience init(setFromGoogleLogin gLogin: GIDGoogleUser){
        self.init()
        self.googlAuthenitcationToken = gLogin.authentication.accessToken
    }
    
    /// Checks if user is a fb or google user and with respect to that logs the user out
    func logOutUser(){
        
    }
    
}
