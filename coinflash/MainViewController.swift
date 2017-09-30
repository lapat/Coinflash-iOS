//
//  MainViewController.swift
//  coinflash
//
//  Created by TJ on 9/26/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

class MainViewController: UIViewController, UITableViewDataSource{
    
    override func viewDidLoad() {
        SideMenuManager.menuWidth = UIScreen.main.bounds.size.width * 0.75
        SideMenuManager.menuDismissOnPush = true
        SideMenuManager.menuPresentMode = .menuSlideIn
        SideMenuManager.menuParallaxStrength = 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "basicCell")
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}
