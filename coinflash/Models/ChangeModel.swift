//
//  ChangeModel.swift
//  coinflash
//
//  Created by quangpc on 3/20/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChangeModel {
    
    let json: JSON
    
    var user_set_primary_coinbase_account_id = ""
    var right_side: CoinType?
    var user_set_primary_coinflash_debit_wallet_id = ""
    var left_side: CoinType?
    var percent_to_invest = 0
    var was_referred = "false"
    var free_months_left = 0
    var invest_minimum = 0
    var invest_on = 0
    var user_set_primary_coinbase_btc_account_id = ""
    var eth_percentage: Int = 0
    var relinked_higher_limit = false
    var number_of_referrals = 0
    var user_set_primary_coinbase_eth_account_id = ""
    var invest_minimum_amount: Double = 0
    var referral_code = ""
    var onboard_status = 0
    var btc_percentage = 0
    var cap = 0
    var agreed_to_tos = 0
    var how_paying = 0
    var plaid_error_code = 0
    var how_often = 0
    
    var coinbase_name = ""
    var coinbaseAccounts = [CoinbaseAccount]()
    var coinbase_avatar_url = ""
    
    var plaidAccounts = [PlaidAccount]()
    
    var wallets = [Walllet]()
    
    var leftPercent: Double = 0.5
    var rightPercent: Double = 0.5
    var timePercent: Double = 0
    var dayLeft = 0
    
    init(json: JSON) {
        self.json = json
        
        user_set_primary_coinbase_account_id = json["user_set_primary_coinbase_account_id"].stringValue
        right_side = CoinType(rawValue: json["right_side"].intValue)
        user_set_primary_coinflash_debit_wallet_id = json["user_set_primary_coinflash_debit_wallet_id"].stringValue
        left_side = CoinType(rawValue: json["left_side"].intValue)
        percent_to_invest = json["percent_to_invest"].intValue
        was_referred = json["was_referred"].stringValue
        free_months_left = json["free_months_left"].intValue
        invest_minimum = json["invest_minimum"].intValue
        invest_on = json["invest_on"].intValue
        user_set_primary_coinbase_btc_account_id = json["user_set_primary_coinbase_btc_account_id"].stringValue
        eth_percentage = json["eth_percentage"].intValue
        relinked_higher_limit = json["relinked_higher_limit"].boolValue
        number_of_referrals = json["number_of_referrals"].intValue
        user_set_primary_coinbase_eth_account_id = json["user_set_primary_coinbase_eth_account_id"].stringValue
        invest_minimum_amount = json["invest_minimum_amount"].doubleValue
        referral_code = json["referral_code"].stringValue
        onboard_status = json["onboard_status"].intValue
        btc_percentage = json["btc_percentage"].intValue
        cap = json["cap"].intValue
        agreed_to_tos = json["agreed_to_tos"].intValue
        how_paying = json["how_paying"].intValue
        plaid_error_code = json["plaid_error_code"].intValue
        how_often = json["how_often"].intValue
        
        var btcPercentage = Double(btc_percentage)/100
        if btcPercentage == 0 {
            btcPercentage = 0.5
        }
        leftPercent = 1 - btcPercentage
        rightPercent = btcPercentage
        
        var totalDay = 7
        var pastDay = 0
        let now = Date()
        let day = Calendar.current.component(.day, from: now)
        var weekDay = Calendar.current.component(.weekday, from: now)-2
        if weekDay < 0 {
            weekDay = 6
        }
        if how_often == 3 {
            //monthly
            let range = Calendar.current.range(of: .day, in: .month, for: now)
            totalDay = range?.count ?? 30
            pastDay = day
        } else if how_often == 2 {
            //weekly
            pastDay = weekDay
        }
        dayLeft = totalDay - pastDay
        let progress = Double(pastDay) / Double(totalDay)
        timePercent = progress
        // banks []
        
        // plaid_accounts []
        for subJson in json["plaid_accounts"].arrayValue {
            let acc = PlaidAccount(json: subJson)
            plaidAccounts.append(acc)
        }
        
        // coinbase accounts
        coinbase_name = json["coinbase_name"].stringValue
        coinbase_avatar_url = json["coinbase_avatar_url"].stringValue
        for coinbaseJson in json["coinbase_accounts"].arrayValue {
            let acc = CoinbaseAccount(json: coinbaseJson)
            if acc.type != "fiat_account" {
                self.coinbaseAccounts.append(acc)
            }
            
        }
        
        // wallets
        for subJson in json["wallets"].arrayValue {
            let acc = Walllet(json: subJson)
            wallets.append(acc)
        }
    }
}

class CoinbaseAccount {
    var id = ""
    var allow_buy = false
    var resource = ""
    var primary_buy = false
    var verified = false
    var allow_withdraw = false
    var created_at = ""
    var instant_buy = false
    var type = ""
    var allow_sell = false
    var instant_sell = false
    var updated_at = ""
    var resource_path = ""
    var name = ""
    var allow_deposit = false
    var currency = ""
    var primary_sell = false
    
    init(json: JSON) {
        id = json["id"].stringValue
        allow_buy = json["allow_buy"].boolValue
        resource = json["resource"].stringValue
        primary_buy = json["primary_buy"].boolValue
        verified = json["verified"].boolValue
        allow_withdraw = json["allow_withdraw"].boolValue
        created_at = json["created_at"].stringValue
        instant_buy = json["instant_buy"].boolValue
        type = json["type"].stringValue
        allow_sell = json["allow_sell"].boolValue
        instant_sell = json["instant_sell"].boolValue
        updated_at = json["updated_at"].stringValue
        resource_path = json["resource_path"].stringValue
        name = json["name"].stringValue
        allow_deposit = json["allow_deposit"].boolValue
        currency = json["currency"].stringValue
        primary_sell = json["primary_sell"].boolValue
    }
    
}

class PlaidAccount {
    var plaid_account_name = ""
    var last_four_digits = ""
    
    init(json: JSON) {
        plaid_account_name = json["plaid_account_name"].stringValue
        last_four_digits = json["last_four_digits"].stringValue
    }
}

class Walllet {
    var balance_amount: Double = 0
    var balance_currency = ""
    var native_balance_amount: Double = 0
    var native_balance_currency = ""
    var resource = ""
    var resource_path = ""
    var name = ""
    var currency_code = ""
    var currency_color = ""
    var currency_name = ""
    var id = ""
    var type = ""
    var primary = false
    
    init(json: JSON) {
        balance_amount = json["balance"]["amount"].doubleValue
        balance_currency = json["balance"]["currency"].stringValue
        native_balance_amount = json["native_balance"]["amount"].doubleValue
        native_balance_currency = json["native_balance"]["currency"].stringValue
        resource = json["resource"].stringValue
        resource_path = json["resource_path"].stringValue
        name = json["name"].stringValue
        currency_code = json["currency"]["code"].stringValue
        currency_color = json["currency"]["color"].stringValue
        currency_name = json["currency"]["name"].stringValue
        id = json["id"].stringValue
        type = json["type"].stringValue
        primary = json["primary"].boolValue
    }
    
}
