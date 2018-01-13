//
//  BuyNowSliderControll.swift
//  coinflash
//
//  Created by Tallal Javed on 13/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

class CryptoPercentSliderControll: UISlider {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var leftSideCurrency, rightSideCurrency: CryptoCurrency!
    var leftPercent, rightPercent: Int!
    
    func updateSliderColor(){
        let leftColor = HelperFunctions.getColorForCryptoCurrency(currency: leftSideCurrency)
        let rightColor = HelperFunctions.getColorForCryptoCurrency(currency: rightSideCurrency)
        
        let color = UIColor.blend(color1: leftColor, intensity1: (CGFloat(Double(leftPercent)/100.0)), color2: rightColor, intensity2: CGFloat(Double(rightPercent)/100.0))
        thumbTintColor = color
        minimumTrackTintColor = color
        maximumTrackTintColor = color
    }
}
