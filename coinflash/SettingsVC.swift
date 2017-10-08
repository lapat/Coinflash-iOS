//
//  SettingsVC.swift
//  coinflash
//
//  Created by TJ on 9/25/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit

class SettingsVC: UITableViewController, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var monthlyButton: UIButton?
    @IBOutlet weak var weeklyButton: UIButton?
    @IBOutlet weak var investChangeControl: UISwitch!
    @IBOutlet weak var changeToInvestSlider: UISlider!
    @IBOutlet weak var changeToInvestSliderValueLabel: UILabel!
    @IBOutlet weak var capOnInvestmentTextField: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.loadGlobalSettings()
        
        // CapOnInvestmentTextField initializations
        capOnInvestmentTextField.delegate = self
        capOnInvestmentTextField.returnKeyType = .done
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 50))
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.items = [
            UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelNumberPad)),
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.doneWithNumberPad))]
        numberToolbar.sizeToFit()
        capOnInvestmentTextField.inputAccessoryView = numberToolbar
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
    
    // Settings Properties
    func loadGlobalSettings(){
        if globalSettings.investHowOften == .monthly{
            monthlyButton?.isSelected = true
            weeklyButton?.isSelected = false
        }else{
            monthlyButton?.isSelected = false
            weeklyButton?.isSelected = true
        }
        
        self.changeToInvestSlider.value = globalSettings.percentOfChangeToInvest
        self.changeToInvestSliderValueLabel.text = "\(Int(globalSettings.percentOfChangeToInvest))%"
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
    
    //Slider chnages
    @IBAction func changeToInvestSliderChanged(sender: UISlider){
        globalSettings.percentOfChangeToInvest = sender.value
        self.changeToInvestSliderValueLabel.text = "\(Int(sender.value))%"
    }
    
    //Cap on investment TextField saved
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func cancelNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
    }
    
    func doneWithNumberPad(){
        capOnInvestmentTextField.resignFirstResponder()
        var temp = capOnInvestmentTextField.text!.remove(at: capOnInvestmentTextField.text!.startIndex)
        //globalSettings.capOnInvestment = Int(temp)
        print(globalSettings.capOnInvestment)
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
