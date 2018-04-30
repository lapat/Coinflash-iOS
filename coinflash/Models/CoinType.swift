//
//  CoinType.swift
//  coinflash
//
//  Created by quangpc on 3/20/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation

enum CoinType: Int {
    case btc = 1, eth = 2, ltc = 3, bch = 7, all = 0
    
    static var allCoins: [CoinType] = [all, btc, eth, ltc, bch]
    static var coins: [CoinType] = [btc, eth, ltc, bch]
    
    var name: String {
        switch self {
        case .btc: return "BTC"
        case .eth: return "ETH"
        case .ltc: return "LTC"
        case .bch: return "BCH"
        case .all: return "ALL"
        }
    }
    
    var fullName: String {
        switch self {
        case .btc: return "Bitcoin"
        case .eth: return "Ethereum"
        case .ltc: return "Litecoin"
        case .bch: return "BitcoinCash"
        case .all: return "ALL"
        }
    }
    
    var icon: String {
        switch self {
        case .btc: return "ic_btc"
        case .eth: return "ic_eth"
        case .ltc: return "ic_ltc"
        case .bch: return "ic_bcc"
        case .all: return ""
        }
    }
    
    var color: UIColor {
        switch self {
        case .btc:
            return btcColor
        case .eth:
            return ethColor
        case .ltc:
            return ltcColor
        case .bch:
            return bchColor
        default:
            return UIColor.clear
        }
    }
    var postfix: String {
        switch self {
        case .btc: return "btc"
        case .eth: return "eth"
        case .ltc: return "ltc"
        case .bch: return "bch"
        case .all: return ""
        }
    }
    static func key(with prefix: String, coin: CoinType, after: String = "")-> String {
        return prefix + coin.postfix + after
    }
    
    var priceRightNowKey: String {
        let prefix = "price_right_now_"
        return CoinType.key(with: prefix, coin: self)
    }
    var totalAmountSpentOn: String {
        let prefix = "total_amount_spent_on_"
        return CoinType.key(with: prefix, coin: self)
    }
    var amountOwned: String {
        let prefix = "amount_"
        return CoinType.key(with: prefix, coin: self, after: "_owned")
    }
}
