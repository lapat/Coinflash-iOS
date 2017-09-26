//
//  MainPageVC.swift
//  coinflash
//
//  Created by Tabish Manzoor on 9/25/17.
//  Copyright © 2017 Tabish Manzoor. All rights reserved.
//

import Foundation
import UIKit

class MainPageVC: UITableViewController{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named:"bg.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        print(size)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
            print("did layout")
        }
    }
    
    // IBactions
    @IBAction func didTapOnMenuButton(sender: UIButton){
        print("tapped on the menu button")
    }
    
    
}
