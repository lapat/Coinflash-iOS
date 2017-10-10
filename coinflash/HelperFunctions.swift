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
    }
    
    
    // MARK: - Coin base Helpers
    
}
