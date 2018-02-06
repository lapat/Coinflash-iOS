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
import FacebookLogin

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{
    
    var userID: String = ""
    var idToken: String = ""
    var fullName: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var email: String = ""
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var reloginPrompt: UILabel!
    
    var fbLoginResult: LoginResult!
    var googleLoginUSer: GIDGoogleUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "678747170744-6o53mljo3a5q9o9avn6jvbm1r7vsjtv9.apps.googleusercontent.com"
        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
        
        loginButton.center = CGPoint(x: view.center.x, y: view.frame.height - 50)
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        reloginPrompt.textColor = UIColor.red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloginPrompt.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        HelperFunctions.loadNSUserDefaults()
        
        if user_isLoggedIn == true{
            if HelperFunctions.isTOCAccepted(){
                //self.performSegue(withIdentifier: "mainPageSegue", sender: self)
                if User.mainUser.type == .facebook{
                    self.performSegue(withIdentifier: "mainPageSegue", sender: self)
                    //self.requestFBLoginToServer(token: User.mainUser.getAuthToken())
                }
                if User.mainUser.type == .google{
                    User.mainUser.googleAuthUser = googleUser
                    self.requestServerForLoginConfirmation(googleUser: User.mainUser.googleAuthUser)
                }
                //self.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
            }else{
                if User.mainUser.type == .facebook{
                    self.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
                    //self.requestFBLoginToServer(token: User.mainUser.getAuthToken())
                }
                if User.mainUser.type == .google{
                    self.requestServerForLoginConfirmation(googleUser: User.mainUser.googleAuthUser)
                }
                //self.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
                //self.
            }
        }
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
        guard error == nil else {
            
          //  print("Error while trying to redirect : \(error)")
            return
        }
        
      //  print("Successful Redirection")
    }
    
    func application(application: UIApplication, openURL url: NSURL,
                     sourceApplication: String?, annotation: AnyObject) -> Bool
    {
        
        let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL!, sourceApplication: sourceApplication,
                                                                   annotation: annotation)
        return googleDidHandle
    }
    
    //MARK: - GID UI SignIn Delegate
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
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
         //   print("ERROR ::\(error.localizedDescription)")
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
     //   print(error)
    }
    
    // Check Google info from server
    func requestServerForLoginConfirmation(googleUser user: GIDGoogleUser){
        let header: HTTPHeaders = ["content-type": "application/x-www-form-urlencoded"]
        let parameter: Parameters = ["id_token": user.authentication.idToken, "mobile_secret": user_mobile_secret]
        SVProgressHUD.show()
        Alamofire.request("\(baseUrl)login2/", method: HTTPMethod.post, parameters: parameter, headers: header)
            .responseJSON { (response) in
            switch response.result{
            case .success:
                SVProgressHUD.dismiss()
                let data = response.result.value as! [String: Any]
                //print(response)
                if data["Invalid ID token"] != nil{
                    // make user login again
                    let alert = UIAlertController(title: "Error", message: "Kindly login again", preferredStyle: UIAlertControllerStyle.alert)
                    let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(okayAction)
                    //self.present(alert, animated: true, completion: nil)
                    // Instead of alert just show the prompt label
                    self.reloginPrompt.isHidden = false
                    HelperFunctions.updateVariablesForUserLoggingOut()
                    return
                }
                googleUser = user
                User.mainUser = User(setFromGoogleLogin: user)
                HelperFunctions.saveLoginInfo(userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
                if HelperFunctions.isTOCAccepted(){
                    OperationQueue.main.addOperation
                    {
                        [weak self] in
                        self?.performSegue(withIdentifier: "mainPageSegue", sender: self)
                    }
                }else{
                    OperationQueue.main.addOperation {
                        [weak self] in
                        self?.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
                    }
                }
            case .failure:
             //   print(response.error)
                SVProgressHUD.dismiss()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      //  print(segue.identifier)
    }

    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // ...
        } else {
         //   print("\(error.localizedDescription)")
        }
    }
}

//MARK:- Facebook Login
extension LoginVC: LoginButtonDelegate{
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        // mage saving the login results here.
        switch result {
        case .cancelled:
            print("canceled")
        case .failed(let error):
            print(error)
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let authToken = token.authenticationToken
            self.fbLoginResult = result
            self.requestFBLoginToServer(token: authToken)
        default:
            print("meh")
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        
    }
    
    func confirmFBLoginFromServer(token: String){
        
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
                    if data["Invalid ID token"] != nil{
                        // make user login again
                        let alert = UIAlertController(title: "Error", message: "Kindly login again", preferredStyle: UIAlertControllerStyle.alert)
                        let okayAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                        alert.addAction(okayAction)
                        //self.present(alert, animated: true, completion: nil)
                        self.reloginPrompt.isHidden = false
                        HelperFunctions.updateVariablesForUserLoggingOut()
                        return
                    }
                    HelperFunctions.saveLoginInfo( userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
                    //User.mainUser = User(setFromGoogleLogin: user)
                 //   let userIDMobile = data["user_id_mobile"]
                  //  let accessToken = data["mobile_access_token"]
                   // let onBoardStatus = data["onboard_status"]
                    User.mainUser = User(setFromFBLogin: self.fbLoginResult, userName: data["name"] as! String)
                    HelperFunctions.saveNSUserDefaults()
                    if HelperFunctions.isTOCAccepted(){
                        OperationQueue.main.addOperation
                            {
                                [weak self] in
                                self?.performSegue(withIdentifier: "mainPageSegue", sender: self)
                        }
                    }else{
                        OperationQueue.main.addOperation {
                            [weak self] in
                            self?.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
                        }
                    }
                case .failure:
                    print(response.error)
                    SVProgressHUD.dismiss()
                }
        }
    }
}
