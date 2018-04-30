//
//  CustomSegmentedControl.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import NYSegmentedControl

class CustomSegmentedControl: NYSegmentedControl, NYSegmentedControlDataSource {
    
    var items = [String]() {
        didSet {
            reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        dataSource = self
        borderWidth = 1
        segmentIndicatorInset = 0
        borderColor = UIColor.hexColor(hex: "DFE2E8")
        backgroundColor = UIColor.hexColor(hex: "F7FAFF")
        segmentIndicatorBackgroundColor = UIColor.white
        titleTextColor = UIColor.hexColor(hex: "B5B5B5")
        selectedTitleTextColor = UIColor.hexColor(hex: "B5B5B5")
        titleFont = UIFont.tstarProBold(size: 13)
        selectedTitleFont = UIFont.tstarProBold(size: 13)
    }
    
    func number(ofSegments control: NYSegmentedControl) -> UInt {
        return UInt(items.count)
    }
    func segmentedControl(_ control: NYSegmentedControl, titleForSegmentAt index: UInt) -> String {
        return items[Int(index)]
    }
    
}
