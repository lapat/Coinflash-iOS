//
//  ManageChangeSegmentCell.swift
//  coinflash
//
//  Created by robert pham on 3/18/18.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit

class ManageChangeSegmentCell: UITableViewCell, ReusableView, NibLoadableView {
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    var valueChanged: (_ index: Int)-> Void = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        segmentedControl.items = ["UNINVESTED", "INVESTED"]
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc private func segmentedControlChanged() {
        valueChanged(Int(segmentedControl.selectedSegmentIndex))
    }
    
}
