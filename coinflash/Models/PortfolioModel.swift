//
//  PortfolioModel.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON
/*
class PortfolioModel {
    
    var price_right_now_eth: Double = 0
    var total_amount_spent_on_eth: Double = 0
    var amount_eth_owned: Double = 0
    
    var total_amount_spent_on_btc: Double = 0
    var amount_btc_owned: Double = 0
    var price_right_now_btc: Double = 0
    
    var price_right_now_ltc: Double = 0
    var total_amount_spent_on_ltc: Double = 0
    var amount_ltc_owned: Double = 0
    
    var price_right_now_bch: Double = 0
    var total_amount_spent_on_bch: Double = 0
    var amount_bch_owned: Double = 0
    
    init(json: JSON) {
        
    }
    
}
*/

struct CoinTransaction {
    var crypto: String!
    var price: Double = 0
    var date: String!
    var type: Int = 0
    var value: String!
    var currency: CoinType = .all
    
    init(json: JSON) {
        crypto = json["coinbase_crypto_amount"].stringValue
        price = json["coinbase_total_amount_spent"].doubleValue
        value = json["coinbase_amount_spent_on_crypto"].stringValue
        date = json["coinbase_time_transaction_will_payout"].stringValue
        type = json["crypto_type"].intValue
        
        var dateStr: String = date
        var truncated = String(dateStr.characters.dropFirst(5))
        truncated = String(truncated.characters.dropLast(10))
        date = truncated
        
        currency = CoinType(rawValue: type) ?? .all
    }
}
