//
//  ConnectRootViewController.swift
//  Petgram
//
//  Created by Saifuding Diliyaer on 11/18/18.
//  Copyright © 2018 CS160. All rights reserved.
//

import UIKit
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit



class ConnectRootViewController: UIViewController {
    
    @IBOutlet weak var fbLoginButton: UIButton!
    
    @IBAction func fbLoginTapped() {
        
        LoadingShade.add()
        User.requestFacebookToken { (tokenResult) in
            LoadingShade.remove()
            switch tokenResult {
            case .failure(let error):
                Logger.log("User.requestFacebookToken Failed. Error: \(error)", logType: .error)
                let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                    overlay.animateOut()
                    self.fbLoginTapped()
                }, cancelAction: { (overlay) in
                    overlay.animateOut()
                })
                overlay.animateIn()
                
            case .success(let fbToken):
                LoadingShade.add()
                User.login(with: fbToken, callback: { (error, user) in
                    LoadingShade.remove()
                    guard error == nil, let user = user else {
                        let overlay = WarningOverlayView(retryWarningWithRetryAction: { (overlay) in
                            overlay.animateOut()
                            self.fbLoginTapped()
                        }, cancelAction: { (overlay) in
                            overlay.animateOut()
                        })
                        overlay.animateIn()
                        return
                    }
                    AppDelegate.shared?.transitionToMain(user: user)
                })
            }
            
        }
        
        self.getFacebookToken { tokenResult in
            switch tokenResult {
            case .failure(let error):
                //                if error.isCancelled {
                //                    completion(.cancelled)
                //                } else {
                //                    self.presentRetry(
                //                        retryHandler: {
                //                            self.connect(
                //                                method: method,
                //                                completion: completion
                //                            )
                //                    },
                //                        cancelHandler: {
                //                            completion(.cancelled)
                //                    }
                //                    )
                //                }
                Logger.log("Error: \(error)", logType: .error)
            case .success(let token):
                
                Logger.log("Got Facebook Token: \(token.tokenString)", logType: .actionLog)
                
                Logger.log("Current Token: \(FBSDKAccessToken.current().tokenString)", logType: .actionLog)
                
                Logger.log("User ID: \(token.userID)", logType: .actionLog)
                
                Logger.log("Expiration Date: \(token.expirationDate)", logType: .actionLog)
                
                
                
                
            }
        }
    }
    
    //    func getFBUserInfo() {
    //        let request = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], accessToken: AccessToken.current, httpMethod: .GET)
    //        request.start { (response, result) in
    //            switch result {
    //            case .success(let value):
    //                print(value.dictionaryValue)
    //            case .failed(let error):
    //                print(error)
    //            }
    //        }
    //    }
    
    //    fileprivate func connect(facebookToken: FBSDKAccessToken, completion: @escaping (ConnectResult) -> ()) {
    //        LoadingShade.add()
    //
    //        let manager = self.user?.authenticatedAFManager
    //            ?? Alamofire.SessionManager.default
    //        let url = apiBaseURL + "/connect/facebook/token"
    //        let params: Alamofire.Parameters = [
    //            "access_token": facebookToken.tokenString!,
    //            "timezone": TimeZone.current.secondsFromGMT() / 60 / 60
    //        ]
    //        manager.request(url, method: .post, parameters: params)
    //            .responseJSON { response in
    //                LoadingShade.remove()
    //
    //                switch self.parseResponse(response: response) {
    //                case .badCredentialsError, .otherNonretryableError:
    //                    completion(.cancelled)
    //                case .otherRetryableError:
    //                    self.presentRetry(
    //                        retryHandler: {
    //                            self.connect(
    //                                facebookToken: facebookToken,
    //                                completion: completion
    //                            )
    //                    },
    //                        cancelHandler: {
    //                            completion(.cancelled)
    //                    }
    //                    )
    //                case .differentUserExists:
    //                    // allow time for facebook connect vc to dismiss
    //                    // I know it sucks :(
    //                    delay(0.5) {
    //                        self.presentSwitchVC(
    //                            method: .facebook,
    //                            switchAction: { connector, completion in
    //                                connector.connect(
    //                                    facebookToken: facebookToken,
    //                                    completion: completion
    //                                )
    //                        },
    //                            completion: { user in
    //                                if let user = user {
    //                                    completion(.loggedIn(user))
    //                                } else {
    //                                    completion(.cancelled)
    //                                }
    //                        }
    //                        )
    //                    }
    //                case .newUser(let user):
    //                    completion(.userCreated(user))
    //                case .loggedIn(let user):
    //                    completion(.loggedIn(user))
    //                case .added(let user):
    //                    LoadingShade.add()
    //                    user.refresh() {
    //                        LoadingShade.remove()
    //                        completion(.added)
    //                    }
    //                }
    //        }
    //    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func getFacebookToken(completion: @escaping (Alamofire.Result<FBSDKAccessToken>) -> ()) {
        if let token = FBSDKAccessToken.current() {
            completion(.success(token))
        } else {
            let login = FBSDKLoginManager()
            let permissions = ["public_profile", "email"]
            
            login.logIn(
                withReadPermissions: permissions,
                from: nil
            ) { result, error in
                if let token = FBSDKAccessToken.current() {
                    completion(.success(token))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(
                        .failure(
                            NSError(
                                domain: NSCocoaErrorDomain,
                                code: NSUserCancelledError,
                                userInfo: nil
                            )
                        )
                    )
                }
            }
        }
    }
}

