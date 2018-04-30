//
//  Utils.swift
//  coinflash
//
//  Created by robert pham on 3/11/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import SVProgressHUD


func showHUD() {
    SVProgressHUD.show()
}
func hideHUD() {
    SVProgressHUD.dismiss()
}

func round(num: Double, to places: Int) -> String {
    let formate = "%." + String(places) + "f"
    let conversion = String(format:formate, num)
    return conversion
}


