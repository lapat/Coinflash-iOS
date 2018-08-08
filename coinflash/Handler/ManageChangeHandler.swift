//
//  ManageChangeHandler.swift
//  coinflash
//
//  Created by quangpc on 3/19/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class ManageChangeHandler {
    
    static let sharedInstance: ManageChangeHandler = ManageChangeHandler()
    
    var change: ChangeModel?
    var preference: UserPreferenceModel?
    var investedTrans = [CCTransaction]()
    var unInvestedTrans = [CCTransaction]()
    
    var needRefreshData = false
    var retryCount = 0
    
    func requestCoinflashUser5(completion: @escaping (_ success: Bool)-> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : String(describing:user_mobile_secret!),
            "user_id_mobile" : String(describing:user_id_mobile!),
            "mobile_access_token" : String(describing:user_mobile_access_token!),
            ]
        
        Alamofire.request("https://coinflashapp.com/coinflashuser5/", method: HTTPMethod.post, parameters: parameters,headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                print(json)
                User.checkLoginStatus(json: json)
                if let changeJson = json.arrayValue.first {
                    let model = ChangeModel(json: changeJson)
                    HelperFunctions.updateOnboardStatus(value: model.onboard_status)
                    self.change = model
                }
                self.retryCount = 0
                completion(true)
            case .failure(_):
                self.retryCount += 1
                if self.retryCount <= 3 {
                    self.requestCoinflashUser5(completion: completion)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func requestCoinFlashFeatchccTransations(completion: @escaping (_ success: Bool)-> Void) {
        let headers: HTTPHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        let parameters: [String: String] = [
            "mobile_secret" : user_mobile_secret,
            "user_id_mobile" : user_id_mobile,
            "mobile_access_token" : user_mobile_access_token,
            "less": "true"
            ]
        Alamofire.request("https://coinflashapp.com/cctransactions2/", method: HTTPMethod.post, parameters: parameters,headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    let preferenceJson = json["user_preferences"]
                    let transactionArray = json["cc_transactions_array"].arrayValue
                    self.preference = UserPreferenceModel(json: preferenceJson)
                    
                    self.investedTrans.removeAll()
                    self.unInvestedTrans.removeAll()
                    let now = Date()
                    for tranJson in transactionArray {
                        let tran = CCTransaction(json: tranJson)
                        if let d = tran.dateObj {
                            let monthDif = Calendar.current.dateComponents([.month], from: d, to: now).month ?? 0
                            if monthDif > 2 || monthDif < -2 {
                                continue
                            }
                        }
                        if tran.amount < 0 {
                            continue
                        }
                        if tran.invested {
                            self.investedTrans.append(tran)
                        } else {
                            self.unInvestedTrans.append(tran)
                        }
                    }
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
    
}
