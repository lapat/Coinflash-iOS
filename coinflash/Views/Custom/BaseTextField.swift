//
//  BaseTextField.swift
//  LGBT
//
//  Created by quangpc on 4/22/16.
//  Copyright © 2016 Freelancer. All rights reserved.
//

import UIKit

class BaseTextField: UITextField {

    @IBInspectable var padding: CGFloat = 0 {
        didSet {
            
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: padding, y: 0, width: bounds.size.width - 2 * padding, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: padding, y: 0, width: bounds.size.width - 2 * padding, height: bounds.size.height)
    }
    
}
