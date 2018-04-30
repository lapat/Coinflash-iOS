//
//  UserPreferenceModel.swift
//  coinflash
//
//  Created by quangpc on 3/20/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON

enum HowOftenType: Int {
    case none = 0, daily = 1, weekly = 2, monthly = 3
}

class UserPreferenceModel {
    
    let json: JSON
    
    var btc_to_invest = 0
    var percent_to_invest = 0
    var btc_percentage = 59
    var invest_on = 0
    var how_often: HowOftenType = .none
    var spare_change_accrued: Double = 0
    var cap = ""
    var spare_change_accrued_percent_to_invest: Double = 0
    
    init(json: JSON) {
        self.json = json
        
        btc_to_invest = json["btc_to_invest"].intValue
        percent_to_invest = json["percent_to_invest"].intValue
        btc_percentage = json["btc_percentage"].intValue
        invest_on = json["invest_on"].intValue
        how_often = HowOftenType(rawValue: json["how_often"].intValue) ?? .none
        
        spare_change_accrued = json["spare_change_accrued"].doubleValue
        cap = json["cap"].stringValue
        spare_change_accrued_percent_to_invest = json["spare_change_accrued_percent_to_invest"].doubleValue
    }
}
