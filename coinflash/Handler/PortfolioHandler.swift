//
//  PortfolioHandler.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class PortfolioHandler {
    
    var portfolioJSON: JSON?
    var graphJson: JSON?
    
    var allTransactions = [CoinTransaction]()
    var transactions = [Int: [CoinTransaction]]()
    
    func requestCoinFlashFeatchwallet(mobile_secret: String,
                                      user_id_mobile: String,
                                      mobile_access_token: String,
                                      completion: @escaping (_ success: Bool)-> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : mobile_access_token,
            "less": "true"
            ]
        
        Alamofire.request("https://coinflashapp.com/coinflashtransactions4/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let json = try? JSON(data: data) else {
                    completion(false)
                    return
                }
                self.portfolioJSON = json
                
                self.transactions.removeAll()
                self.allTransactions.removeAll()
                for tranJson in json["coinflash_transactions"].arrayValue {
                    let tran = CoinTransaction(json: tranJson)
                    self.allTransactions.append(tran)
                    if self.transactions[tran.type] == nil {
                        self.transactions[tran.type] = [tran]
                    } else {
                        self.transactions[tran.type]?.append(tran)
                    }
                }
                
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    func requestCryptoRates(completion: @escaping (_ success: Bool)-> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fromDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        let date = formatter.string(from: fromDate!)
        let dateFormate = formatter.date(from: date)
        let DateToString = formatter.string(from: dateFormate!)
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : user_mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : user_mobile_access_token,
            "after" : DateToString
        ]
        
        Alamofire.request("https://coinflashapp.com/coinflashprice/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let json = try? JSON.init(data: data) else {
                    completion(false)
                    return
                }
                self.graphJson = json
                
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func dummyData() {
        
        var dummy: [String: Any] = ["total_amount_spent_on_btc": 10000.0,
                     "amount_btc_owned": 1,
                     "price_right_now_btc": 9000.0,
                     "price_right_now_eth": 500.0,
                     "total_amount_spent_on_eth": 11000.0,
                     "amount_eth_owned": 13,
                     "price_right_now_ltc": 150,
                     "total_amount_spent_on_ltc": 450.0,
                     "amount_ltc_owned": 3.5,
                     "price_right_now_bch": 99,
                     "total_amount_spent_on_bch": 250,
                     "amount_bch_owned": 2.1]
        dummy["coinflash_transactions"] = [
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 1],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 1],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 2],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 2],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 3],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 3],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 7],
            ["coinbase_crypto_amount": 0.12,
             "coinbase_total_amount_spent": 300,
             "coinbase_amount_spent_on_crypto": 400,
             "coinbase_time_transaction_will_payout": 2018-20-02,
             "crypto_type": 7]
        ]
        
        let json = JSON(dummy)
        self.portfolioJSON = json
        
        self.transactions.removeAll()
        self.allTransactions.removeAll()
        for tranJson in json["coinflash_transactions"].arrayValue {
            let tran = CoinTransaction(json: tranJson)
            self.allTransactions.append(tran)
            if self.transactions[tran.type] == nil {
                self.transactions[tran.type] = [tran]
            } else {
                self.transactions[tran.type]?.append(tran)
            }
        }
    }
}
