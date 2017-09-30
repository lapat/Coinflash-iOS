//
//  SettingsVC.swift
//  coinflash
//
//  Created by TJ on 9/25/17.
//  Copyright © 2017 TJ. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UITableViewController, UIGestureRecognizerDelegate{
    
    @IBOutlet weak var monthlyButton: UIButton?
    @IBOutlet weak var weeklyButton: UIButton?
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        let backgroundImage = UIImage(named:"bg.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @IBAction func didTapBackButton(for button: UIButton){
        print("button tapped")
        self.navigationController?.popViewController(animated: true)
    }
    
    // Nav pop with swipe recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //Setting taps actions
    @IBAction func didTapOnMonthlyWeekly(sender: UIButton){
        if sender == monthlyButton{
            if sender.isSelected == false{
                sender.isSelected = true
                weeklyButton?.isSelected = false
                
            }
           // else if sender.isSelected == true{
           //     sender.isSelected = false
           //     weeklyButton?.isSelected = true
           // }
        }
        
        if sender == weeklyButton{
            if sender.isSelected == false{
                sender.isSelected = true
                monthlyButton?.isSelected = false
            }
           // else if sender.isSelected == true{
           //     sender.isSelected = false
           //     monthlyButton?.isSelected = true
           // }
        }
    }

    // tableview delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.row == 1{
            return 70
        }
        if indexPath.row == 2{
            return 120
        }
        return UITableViewAutomaticDimension
    }
}


