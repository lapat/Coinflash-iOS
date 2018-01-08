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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().clientID = "678747170744-6o53mljo3a5q9o9avn6jvbm1r7vsjtv9.apps.googleusercontent.com"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        HelperFunctions.loadNSUserDefaults()
        
        if user_isLoggedIn == true{
            if HelperFunctions.isTOCAccepted(){
                self.performSegue(withIdentifier: "mainPageSegue", sender: self)
                //self.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
            }else{
                self.performSegue(withIdentifier: "tocAcceptSegue", sender: self)
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
              //  print(response)
                HelperFunctions.saveLoginInfo(user: user, userIdMobile: data["user_id_mobile"] as! String, mobileAccessToken: data["mobile_access_token"] as! String, onboardStatus: data["onboard_status"] as! String)
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
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
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
