//
//  LoginVC.swift
//  coinflash
//
//  Created by tallal on 9/30/17.
//  Copyright © 2017 CoinFlash. All rights reserved.
//

import Foundation
import UIKit

class LoginVC: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{
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
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            print("User id is \(String( userId!))")
            
            let idToken = user.authentication.idToken // Safe to send to the server
            print("Authentication idToken is \(String( describing: idToken))")
            let fullName = user.profile.name
            print("User full name is \(String( describing: fullName))")
            let givenName = user.profile.givenName
            print("User given profile name is \(String( describing: givenName))")
            let familyName = user.profile.familyName
            print("User family name is \(String( describing: familyName))")
            let email = user.profile.email
            print("User email address is \(String( describing: email))")
            // ...
        } else {
            print("ERROR ::\(error.localizedDescription)")
        }
    }
    
    // Finished disconnecting |user| from the app successfully if |error| is |nil|.
    public func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!)
    {
        
    }

    
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
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
