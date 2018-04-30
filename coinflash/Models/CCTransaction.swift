//
//  CCTransaction.swift
//  coinflash
//
//  Created by quangpc on 3/20/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SwiftyJSON

class CCTransaction {
    
    let json: JSON
    
    var name = ""
    var date = ""
    var transaction_id = ""
    var amount: Double = 0
    var invested = false
    var spareChange: Double = 0
    var dateObj: Date?
    
    static let dateFormat: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "yyyy-MM-dd"
        return fm
    }()
    
    init(json: JSON) {
        self.json = json
        
        name = json["cctransaction_name"].stringValue
        let dateStr = json["cctransaction_date"].stringValue
        if let d = CCTransaction.dateFormat.date(from: dateStr) {
            dateObj = d
        }
        date = String(dateStr.characters.dropFirst(5))
        
        transaction_id = json["coinbase_transaction_id"].stringValue
        amount = json["cctransaction_amount"].doubleValue
        if transaction_id.isEmpty {
            invested = false
        } else {
            invested = true
        }
        
        spareChange = ceil(amount) - amount
    }
    
}
