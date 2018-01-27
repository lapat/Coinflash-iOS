//
//  User.swift
//  coinflash
//
//  Created by Tallal Javed on 25/01/2018.
//  Copyright © 2018 CoinFlash. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

enum UserType: Int, Codable{
    case facebook = 1
    case google = 2
    case none = 3
}

class User: NSObject, NSCoding {
    // Properties
    /// Keeps User profile pucture url. Could have been fetched from coinflashServer, gmail or fb
    var profilePicURL: URL!
    var name: String!
    /// Type of the user logged in
    var type: UserType = .none
    var fbToken: String!
    var fbUserID: String!
    var googleAuthUser: GIDGoogleUser!
    
    static var mainUser = User()
    
    override init() {
        super.init()
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as? String ?? ""
        self.profilePicURL = decoder.decodeObject(forKey: "profilePicURL") as? URL ?? nil
        self.fbUserID = decoder.decodeObject(forKey: "fbUserID") as? String ?? ""
        self.fbToken = decoder.decodeObject(forKey: "fbToken") as? String ?? nil
        if self.fbUserID != "" {
            self.type = .facebook
        }else{
            self.type = .google
        }
        //self.type = UserType(rawValue: (decoder.decodeObject(forKey: "type") as! Int)) ?? .none
        self.googleAuthUser = decoder.decodeObject(forKey: "googleAuthUser") as? GIDGoogleUser ?? nil
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(profilePicURL, forKey: "profilePicURL")
        coder.encode(self.fbUserID, forKey: "fbUserID")
        coder.encode(self.type.rawValue, forKey: "type")
        coder.encode(fbToken, forKey: "fbToken")
        coder.encode(googleAuthUser, forKey: "googleAuthUser")
    }
    
    //MARK: - Facebook
    /// Sets the fb login info from fb login result object - Seriously fb why no prefix in object names?????
    convenience init(setFromFBLogin fbResult: LoginResult, userName: String){
        self.init()
        switch fbResult{
        case .cancelled:
            break
        case .failed(let error):
            print(error)
        case .success(let grantedPermissions, let declinedPermissions, let token):
            let _ = grantedPermissions
            let _ = declinedPermissions
            self.parseFBToken(token: token)
            type = .facebook
            self.name = userName
        }
    }
    
    func parseFBToken(token: AccessToken){
        self.fbToken = token.authenticationToken
        self.fbUserID = token.userId
        let pic = String(format: "https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", token.userId!)
        self.profilePicURL = URL(string: pic)
    }
    
    //MARK:- Google
    /// Sets the user object from google user login info
    convenience init(setFromGoogleLogin gUser: GIDGoogleUser){
        self.init()
        self.name = gUser.profile.name
        self.profilePicURL = gUser.profile.imageURL(withDimension: 200)
        self.googleAuthUser = gUser
        type = .google
    }
    
    //MARK: - General
    func getAuthToken() -> String{
        if type == .facebook{
            return fbToken
        }
        if type == .google{
            return googleAuthUser.authentication.accessToken
        }
        return ""
    }
    
    func facebookLogIn(){
        
    }
    
    func googleLogin(){
        
    }
    
    func facebookLogOut(){
        
    }
    
    func googleLogOut(){
        
    }
    
    func logOut(){
        self.profilePicURL = nil
        self.name = nil
        self.type = .none
        self.fbUserID = nil
        self.fbToken = nil
        self.googleAuthUser = nil
    }
}
