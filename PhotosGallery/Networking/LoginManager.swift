//
//  LoginManager.swift
//  PhotosGallery
//
//  Created by SS on 5/8/19.
//  Copyright © 2019 SergiySachuk. All rights reserved.
//

import Foundation

struct LoginManager {
    
    static func login(from controller: UINavigationController,
                      withScopes scopes: [LinkedInScope] = [.all],
                      success: EmptySuccessHandler?,
                      failure: FailureHandler?) {
        
        guard client != nil else { failure?(InstagramError.missingClientIdOrRedirectURI); return }
        
        let authURL = buildAuthURL(scopes: scopes)
        
        //print(authURL)
        
        let vc = LinkedInLoginViewController(authURL: authURL, success: { code, state in
            //Step 3. Exchange code to accessToken
            print("code:", code, "\nstate:", state)
            
            //verify state is equal to the state in the login request
            self.exchangeCodeForAcessToken(code: code, completion: { accessToken in
                
                if let accessToken = accessToken, !accessToken.isEmpty {
                    
                    LinkedInAPI.shared.fetchProfile(token: accessToken, completion: { (profile) in
                        
                        if let profile = profile {
                            //Save account to Realm
                            let account = Account(profile: profile)
                            RealmManager.createOnThisThread(account)
                            
                            //Save access token to keychain
                            let key = profile.id
                            guard self.storeAccessToken(accessToken, key: key) else {
                                failure?(InstagramError.keychainError(code: self.keychain.lastResultCode))
                                return
                            }
                            print("retrievedAccessToken:", self.retrieveAccessToken(key: key) as Any)
                            success?()
                        }
                    })
                    
                    //DispatchQueue.main.async {
                    controller.popViewController(animated: true)
                    //
                }
            })
            
        }, failure: failure)
        controller.show(vc, sender: nil)
    }
    
}
