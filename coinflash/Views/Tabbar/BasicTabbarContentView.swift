//
//  BasicTabbarContentView.swift
//  CoinFlash
//
//  Created by robert pham on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class BasicTabbarContentView: ESTabBarItemContentView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.hexColor(hex: "3e3e3e").withAlphaComponent(0.5)
        highlightTextColor = UIColor.hexColor(hex: "3E3E3E")
        iconColor = UIColor.hexColor(hex: "3e3e3e").withAlphaComponent(0.5)
        highlightIconColor = UIColor.hexColor(hex: "3E3E3E")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
