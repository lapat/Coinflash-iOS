//
//  User.swift
//  coinflash
//
//  Created by quangpc on 3/19/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

class User {
    
    class func logoutNow() {
        guard let app = UIApplication.shared.delegate as? AppDelegate else { return }
        HelperFunctions.updateVariablesForUserLoggingOut()
        app.goToLoginPage()
    }
    
    class func checkLoginStatus(json: JSON) {
        if let error = json["error"].string {
            if error == "access token doesnt match" {
                logoutNow()
            }
        }
    }
}
