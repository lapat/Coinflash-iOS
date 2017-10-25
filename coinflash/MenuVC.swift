//
//  MenuVC.swift
//  coinflash
//
//  Created by Tabish Manzoor on 10/4/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SDWebImage

class MenuVC: UIViewController {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.userImageView.clipsToBounds = true
        self.userImageView.layer.cornerRadius = self.userImageView.bounds.width/2
        self.nameLabel.text = googleUser.profile.name
        self.userImageView.sd_setShowActivityIndicatorView(true)
        self.userImageView.sd_setIndicatorStyle(UIActivityIndicatorViewStyle.gray)
        self.userImageView.sd_setImage(with: googleUser.profile.imageURL(withDimension: 200), completed: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // View Navigation:
    @IBAction func didTapOnSettings(sender: UIButton){
        //sendSignal(withMessage: "Account Settings")
        let nvController = (UIApplication.shared.delegate as! AppDelegate).mainNavController
        if nvController!.topViewController!.isKind(of: AccountSettingsVC){
            dismiss(animated: true, completion: nil)
            return
        }
        nvController?.popViewController(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "account-settings-view")
        nvController?.pushViewController(newViewController, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOnPortFolioButton(sender: UIButton){
        //sendSignal(withMessage: "Account Settings")
        let nvController = (UIApplication.shared.delegate as! AppDelegate).mainNavController
        if nvController!.topViewController!.isKind(of: BuyPageController) {
            dismiss(animated: true, completion: nil)
            return
        }
        nvController?.popViewController(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "buypage-view")
        nvController?.pushViewController(newViewController, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOnManageChangeButton(sender: UIButton){
        //sendSignal(withMessage: "Account Settings")
        let nvController = (UIApplication.shared.delegate as! AppDelegate).mainNavController
        if (nvController!.topViewController!.isKind(of: MainViewController )){
            dismiss(animated: true, completion: nil)
            return
        }
        nvController?.popViewController(animated: false)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyboard.instantiateViewController(withIdentifier: "mainpage-view")
        nvController?.pushViewController(newViewController, animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func sendSignal(withMessage message: String)  {
        print(message)
    }
    
    @IBAction func didTapLogoutButton(){
        //let header: HTTPHeaders = []
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token]
        SVProgressHUD.show()
        Alamofire.request("\(baseUrl)signout2/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    let data = response.result.value as! [String: Any]
                    print(data)
                    // Dismiss all views and load the login view
                    user_isLoggedIn = false
                    
                    //let nvController = (UIApplication.shared.delegate as! AppDelegate).mainNavController
                    //nvController?.view.removeFromSuperview()
                    
                    // get the present storyboard
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyboard.instantiateViewController(withIdentifier: "login-view")
                    self.show(newViewController, sender: self)
 
                    HelperFunctions.updateVariablesForUserLoggingOut()
                    
                    SVProgressHUD.dismiss()
                case .failure:
                    print(response.error as Any)
                    SVProgressHUD.dismiss()
                }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
