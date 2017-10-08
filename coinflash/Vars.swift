//
//  Vars.swift
//  coinflash
//
//  Created by Tallal Javed on 10/8/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation

/// General user apis
var baseUrl = "https://coinflashapp.com/"
var user_id_token: String!
var user_mobile_secret: String! = "8dkkaiei20kdjkwoeo29ddkskalw82asD!"
var user_id_mobile: String!
var user_mobile_access_token: String!
var user_isLoggedIn: Bool!

var googleUser: GIDGoogleUser!


// Settings Page Global Vars
struct GlobalSettings{
    var investChange: Bool!
    enum InvestChange{
        case monthly
        case weekly
    }
    var changeToInvest: Int!
    var capOnInvestment: Int!
    var hasBitcoinWallet: Bool!
    var hasEtherWaleet: Bool!
    var hasPaymentMethod: Bool!
    init() {
        
    }
}

var globalSettings: GlobalSettings!
