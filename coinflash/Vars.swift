//
//  Vars.swift
//  coinflash
//
//  Created by Tallal Javed on 10/8/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation

// General user apis
var baseUrl = "https://coinflashapp.com/"
var user_id_token: String!
var user_mobile_secret: String! = "8dkkaiei20kdjkwoeo29ddkskalw82asD!"
var user_id_mobile: String!
var user_mobile_access_token: String!
var user_isLoggedIn: Bool!
var user_onboard_status: OnBoardStatus!

var googleUser: GIDGoogleUser!
var PlaidBankInfoData = [PlaidInfo]()

enum OnBoardStatus{
    case didNotAcceptTOC
    case agreedTOCNoPlaidOrCoinbase
    case linkedPlaidButNoCoinbase
    case linkedCoinbaseButNoPlaid
    case linkedPlaidAndCoinbase
}


// MARK: - Settings Page Global Vars
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


// MARK: - Transactions
struct TRansactionInfo{
    var cctransaction_name: String!
    var cctransaction_date: String!
    var cctransaction_coinbase_transaction_id: String!
    var cctransaction_invested: String!
    var cctransaction_amount: String!
    init(){
        cctransaction_date = ""
        cctransaction_name = ""
        cctransaction_coinbase_transaction_id = ""
        cctransaction_invested = ""
        cctransaction_amount = ""
    }
}

// MARK: - Crypto Info
struct TCryptoInfo{
    var TCryptoInfo_crypto: String!
    var TCryptoInfo_price: String!
    var TCryptoInfo_Date: String!
    var TCryptoInfo_type: String!
    var TCryptoInfo_Value: String!
    init(){
        TCryptoInfo_crypto = ""
        TCryptoInfo_price = ""
        TCryptoInfo_Date = ""
        TCryptoInfo_type = ""
        TCryptoInfo_Value = ""
    }
}
var cctransaction_global: TRansactionInfo! = TRansactionInfo()
var TCryptoInfo_global: TCryptoInfo! = TCryptoInfo()


// MARK: - Coinbase
struct CoinbaseInfo{
    var accessToken: String!
    var refreshToken: String!
    var expiresIn: NSNumber!
    var scope: String!
    var tokenType : String!
    var loggedIn: Bool
    init(){
        accessToken = ""
        refreshToken = ""
        expiresIn = 0
        loggedIn = false
    }
}
var coinbaseInfoObject: CoinbaseInfo = CoinbaseInfo()


// MARK: - Plaid
struct PlaidInfo{
    var accessToken: String!
    var loggedIn: Bool
    init(){
        accessToken = ""
        loggedIn = false
    }
}
var plaidInfoObject: PlaidInfo = PlaidInfo()
