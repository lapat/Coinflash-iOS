//
//  BuyPageController+UIPickerVIew.swift
//  coinflash
//
//  Created by Tallal Javed on 16/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

extension BuyPageController: UIPickerViewDelegate{
    
}

extension BuyPageController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return HelperFunctions.getCryptoCurrencyFromCode(code: (row+1)).rawValue
    }
}
