//
//  LinkAllDoneViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class LinkAllDoneViewController: UIViewController, AuthenStoryboardInstance {

    @IBOutlet weak var linkCoinbaseIcon: UIImageView!
    @IBOutlet weak var linkCardIcon: UIImageView!
    @IBOutlet weak var cardTableView: UITableView!
    
    let cellIden = "cell"
    
    var plaidAccounts = [JSON]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCoinFlashUserInfo()
    }
    
    fileprivate func reloadUserData() {
        func icon(isDone: Bool) -> UIImage? {
            let name = isDone ? "check_circle" : "check_circle_fail"
            return UIImage(named: name)
        }
        
        linkCoinbaseIcon.image = icon(isDone: HelperFunctions.isCoinbaseLoggedIn())
        linkCardIcon.image = icon(isDone: HelperFunctions.isPlaidLoggedIn())
    }

    func getCoinFlashUserInfo(){
        let parameter: Parameters = ["mobile_secret": user_mobile_secret, "user_id_mobile": user_id_mobile, "mobile_access_token": user_mobile_access_token]
        SVProgressHUD.show(withStatus: "Loading Account info")
        UIApplication.shared.beginIgnoringInteractionEvents()
        Alamofire.request("\(baseUrl)coinflashuser3/", method: HTTPMethod.post, parameters: parameter)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(let value):
                    let json = JSON(value)
                    let accounts = json[0]["plaid_accounts"].arrayValue
                    self.plaidAccounts = accounts
                    
                    self.cardTableView.reloadData()
                    // dismiss the progress hud
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                case .failure:
                    SVProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                self.reloadUserData()
        }
    }
    
    @IBAction func getStartedButtonPressed(_ sender: Any) {
        guard let app = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        app.goToMainPage()
    }
    

}

extension LinkAllDoneViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plaidAccounts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIden)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellIden)
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            cell?.contentView.backgroundColor = UIColor.clear
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 20)
            cell?.textLabel?.textColor = UIColor.white
        }
        
        cell?.textLabel?.text = ("**** **** ****\(plaidAccounts[indexPath.row]["last_four_digits"].stringValue)")
        plaidInfoObject.loggedIn = true
        
        return cell!
    }
}
