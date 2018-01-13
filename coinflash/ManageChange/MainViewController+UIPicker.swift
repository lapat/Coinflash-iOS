//
//  MainViewController+UIPicker.swift
//  coinflash
//
//  Created by Tallal Javed on 13/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

extension MainViewController: UIPickerViewDelegate {
    
}

extension MainViewController: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "ROW"
    }
}
