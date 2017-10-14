//
//  LoginVC.swift
//  coinflash
//
//  Created by tallal on 9/30/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SVProgressHUD

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{
    
    var userID: String = ""
    var idToken: String = ""
    var fullName: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
        guard error == nil else {
            
            print("Error while trying to redirect : \(error)")
            return
        }
        
        print("Successful Redirection")
    }
    
    //MARK: GIDSignIn Delegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!)
    {
        if (error == nil) {
            // save all the data in view settings
            self.userID = user.userID
            self.idToken = user.authentication.idToken
            self.fullName = user.profile.name
            self.givenName = user.profile.givenName
            self.familyName = user.profile.familyName
            
            
            // Perform any operations on signed in user here.
            //let userId = user.userID                  // For client-side use only!
            //print("User id is \(String(describing: String( userId!)))")
            
            //let idToken = user.authentication.idToken // Safe to send to the server
            //print("Authentication idToken is \(String( describing: idToken))")
            //let fullName = user.profile.name
            //print("User full name is \(String( describing: fullName))")
            //let givenName = user.profile.givenName
            //print("User given profile name is \(String( describing: givenName))")
            //let familyName = user.profile.familyName
            //print("User family name is \(String( describing: familyName))")
            //let email = user.profile.email
            //print("User email address is \(String( describing: email))")
            
            // save info and send to server
            
            self.requestServerForLoginConfirmation(googleUser: user)
            
        } else {
            print("ERROR ::\(error.localizedDescription)")
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        
    }
    
    // Check Google info from server
    func requestServerForLoginConfirmation(googleUser user: GIDGoogleUser){
        let header: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]
        let parameter: Parameters = ["id_token": user.authentication.idToken, "mobile_secret": user_mobile_secret]
        print(user.authentication.idToken)
        SVProgressHUD.show()
        Alamofire.request("\(baseUrl)login2/", method: HTTPMethod.post, parameters: parameter, headers: header)
            .validate()
            .responseJSON { (response) in
            switch response.result{
            case .success:
                let data = response.result.value as! [String: Any]
                HelperFunctions.saveLoginInfo(user: user, userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "mainPageSegue", sender: self)
            case .failure:
                print(response.error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        if user_isLoggedIn == true{
            self.performSegue(withIdentifier: "mainPageSegue", sender: self)
        }
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // ...
        } else {
            print("\(error.localizedDescription)")
        }
    }
}
