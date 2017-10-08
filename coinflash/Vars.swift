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
    var investHowOften: InvestChangeHowOften!
    enum InvestChangeHowOften{
        case monthly
        case weekly
    }
    var percentOfChangeToInvest: Float!
    var capOnInvestment: Int!
    var hasBitcoinWallet: Bool!
    var hasEtherWaleet: Bool!
    var hasPaymentMethod: Bool!
    init() {
        investHowOften = .monthly
        investChange = true
        percentOfChangeToInvest = 100.0
        capOnInvestment = 100
        hasBitcoinWallet = false
        hasEtherWaleet = false
        hasPaymentMethod = false
    }
}
var globalSettings: GlobalSettings = GlobalSettings()


// Transactions
struct TRansactionInfo{
    var cctransaction_name: String!
    var cctransaction_date: String!
    var cctransaction_amount: Float!
    init(){
        cctransaction_date = ""
        cctransaction_name = ""
        cctransaction_amount = 0
    }
}
var cctransaction_global: TRansactionInfo! = TRansactionInfo()

