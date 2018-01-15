//
//  MainViewController+UIPicker.swift
//  coinflash
//
//  Created by Tallal Javed on 13/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

extension MainViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1{
            // check component 0 does not have the same row selected
            let selectedRowInComp0 = pickerView.selectedRow(inComponent: 0)
            if selectedRowInComp0 == row {
                if selectedRowInComp0 == 0{
                    pickerView.selectRow(1, inComponent: 0, animated: true)
                }else{
                    pickerView.selectRow(selectedRowInComp0-1, inComponent: 0, animated: true)
                }
            }
        }
        
        if component == 0{
            // check component 0 does not have the same row selected
            let selectedRowInComp1 = pickerView.selectedRow(inComponent: 1)
            if selectedRowInComp1 == row {
                if selectedRowInComp1 == 0{
                    pickerView.selectRow(1, inComponent: 1, animated: true)
                }else{
                    pickerView.selectRow(selectedRowInComp1-1, inComponent: 1, animated: true)
                }
            }
        }
    }
}

extension MainViewController: UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyNamesForPickerView[row]
    }
    
}
