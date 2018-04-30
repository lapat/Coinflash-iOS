//
//  CoinSegmentedControl.swift
//  coinflash
//
//  Created by robert pham on 3/17/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

class CoinSegmentedControl: UIControl {

    private var buttons = [UIButton]()
    private let lineView = UIView()
    private let indicatorView = UIView()
    
    var selectedIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func selectedCoin()-> CoinType {
        return CoinType.allCoins[selectedIndex]
    }
    
    private func setup() {
        for i in 0..<CoinType.allCoins.count {
            let type = CoinType.allCoins[i]
            let button = UIButton(type: .custom)
            button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
            button.setTitleColor(UIColor.hexColor(hex: "B5B5B5"), for: .normal)
            button.setTitleColor(UIColor.hexColor(hex: "3255FF"), for: .selected)
            button.titleLabel?.font = UIFont.tstarProBold(size: 14)
            if !type.icon.isEmpty {
                button.setImage(UIImage(named: type.icon), for: .normal)
                button.setTitle("  \(type.name)", for: .normal)
            } else {
                button.setTitle(type.name, for: .normal)
            }
            button.tag = i
            buttons.append(button)
            addSubview(button)
        }
        addSubview(lineView)
        addSubview(indicatorView)
        indicatorView.backgroundColor = UIColor.hexColor(hex: "3255FF")
        lineView.backgroundColor = UIColor.hexColor(hex: "F3F3F3")
        
        layout()
    }
    
    @objc func buttonPressed(sender: UIButton) {
        if sender.tag != selectedIndex {
            selectedIndex = sender.tag
            updateSelectedIndicator()
            sendActions(for: .valueChanged)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    private func layout() {
        guard buttons.count > 0 else {
            return
        }
        var startX: CGFloat = 0
        let buttonWidth = bounds.width / CGFloat(buttons.count)
        for i in 0..<buttons.count {
            let button = buttons[i]
            button.frame = CGRect(x: startX, y: 0, width: buttonWidth, height: bounds.height)
            if selectedIndex == i {
                indicatorView.frame = CGRect(x: startX, y: bounds.height - 2, width: buttonWidth, height: 2)
            }
            startX += buttonWidth
            
        }
        lineView.frame = CGRect(x: 0, y: bounds.height - 1, width: bounds.width, height: 1)
        
    }

    private func updateSelectedIndicator() {
        if buttons.count == 0 {
            return
        }
        for i in 0..<buttons.count {
            let button = buttons[i]
            button.isSelected = selectedIndex == i
        }
        let selectedButtonFrame = buttons[selectedIndex].frame
        let newFrame = CGRect(x: selectedButtonFrame.minX, y: bounds.height - 2, width: selectedButtonFrame.width, height: 2)
        UIView.animate(withDuration: 0.2) {
            self.indicatorView.frame = newFrame
        }
    }
}
