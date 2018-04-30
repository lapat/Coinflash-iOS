//
//  SignInViewController.swift
//  CoinFlash
//
//  Created by quangpc on 3/6/18.
//  Copyright © 2018 quangpc. All rights reserved.
//

import UIKit
import Alamofire
import FacebookLogin
import SVProgressHUD
import SwiftyJSON

class SignInViewController: UIViewController, AuthenStoryboardInstance {
    
    var fbLoginResult: LoginResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    @IBAction func googleButtonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func facebookButtonPressed(_ sender: Any) {
        let manager = LoginManager()
        manager.logOut()
        manager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            self.facebookDidCompleteLogin(result: result)
        }
    }
    
    fileprivate func goToLinkPages() {
        if HelperFunctions.isTOCAccepted() {
            AppDelegate.checkOnboardStatus()
        } else {
            let tocVC = TOCVC.storyboardInstance() as TOCVC
            self.navigationController?.pushViewController(tocVC, animated: true)
        }
    }
    
}

extension SignInViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if user != nil && error == nil {
            signInWithGoogle(user: user)
        }
    }
    
    fileprivate func signInWithGoogle(user: GIDGoogleUser) {
        
        let header: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
        let parameter: Parameters = ["id_token": user.authentication.idToken, "mobile_secret": user_mobile_secret]
        print(user.authentication.idToken)
        showHUD()
        Alamofire.request("\(baseUrl)login2/", method: HTTPMethod.post, parameters: parameter, headers: header)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    hideHUD()
                    guard let data = response.result.value as? [String: Any], let _ = data["user_id_mobile"] as? String else {
                        return
                    }
                    HelperFunctions.saveLoginInfo(userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
                    self.goToLinkPages()
                case .failure:
                    hideHUD()
                }
        }
    }
    
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        print(error)
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
}

extension SignInViewController {
    func facebookDidCompleteLogin(result: LoginResult) {
        // mage saving the login results here.
        switch result {
        case .cancelled:
            print("canceled")
        case .failed(let error):
            print(error)
        case .success(_, _, let token):
            let authToken = token.authenticationToken
            self.fbLoginResult = result
            self.requestFBLoginToServer(token: authToken)
        }
    }
    
    func requestFBLoginToServer(token: String){
        //let header: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]
        let parameter: Parameters = ["accessToken": token, "mobile_secret": user_mobile_secret]
        SVProgressHUD.show()
        Alamofire.request("https://coinflashapp.com/Social/SignInFB", method: HTTPMethod.post, parameters: parameter)
            .responseJSON { (response) in
                switch response.result{
                case .success:
                    //print(response.value)
                    SVProgressHUD.dismiss()
                    let data = response.result.value as! [String: Any]
                    //print(response)
                    if data["Invalid ID token"] != nil || data["mobile_access_token"] == nil{
                        // make user login again
                        let alert = UIAlertController(title: "Error", message: "Kindly login again", preferredStyle: UIAlertControllerStyle.alert)
                        let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okayAction)

                        HelperFunctions.updateVariablesForUserLoggingOut()
                        return
                    }
                    HelperFunctions.saveLoginInfo( userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
                    
                    HelperFunctions.saveNSUserDefaults()
                    self.goToLinkPages()
                case .failure:
                    SVProgressHUD.dismiss()
                }
        }
    }
}
