//
//  ChatFlow.swift
//  214-demo-community
//
//  Created by Andrii Selivanov on 8/16/19.
//  Copyright © 2019 214alpha. All rights reserved.
//

import Foundation
import FlowKit
import CometChatPro
import SDWebImage

class ChatFlow: BaseFlow {
    
    let navigationController: UINavigationController = {
        
        // Get our default navigation controller to conform to the flow process
        let vc = DefaultNavigationController()
        
        // Create the storyboard
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        // Create the chat viewController
        let chatViewController = storyBoard.instantiateViewController(withIdentifier: "embeddedViewContrroller") as! EmbeddedViewController
        
        // Make back button work on our own controller
        vc.navigationBar.isHidden = true
        
        // Add our own chatViewController to the navigation view controller
        vc.viewControllers = [chatViewController]
        
        // Return the navigation view controller which contains the chat
        return vc
        
    }()
    
    override func rootViewController() -> UIViewController {
        return navigationController
    }
    
}

func ChatLogin(memberID:String, rawAccessToken:String, URLString:String) -> Bool {
    
    if memberID == "" {
        return Contants.communityMemberChatLoggedIn
    }
    
    // Create a semaphore for syncronous task
    let semaphore = DispatchSemaphore(value: 0)
    
    // Create URLSession for the Chat-Auth-Token Request
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    // Create a URL object from the URLString
    let url = URL(string: URLString as String)
    
    // Create NSMutableURLRequest so that we can set custom headers
    let request : NSMutableURLRequest = NSMutableURLRequest(url: url!)
    
    // Set the http method to "POST"
    request.httpMethod = "POST"
    
    // Add a Content-Type header as sometimes if it's missing certain servers can cause issues
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Add an accept header which accepts everything
    request.addValue("*/*", forHTTPHeaderField: "Accept")
    
    // Set our rawAccessToken which contains the JWT as an Authorization-Bearer as it's necessary for auth
    request.setValue(rawAccessToken, forHTTPHeaderField: "Authorization-Bearer")
    
    // Start the dataTask which upon successful completition would provide us with the Chat-Auth-Token
    let dataTask = session.dataTask(with: request as URLRequest) {
        data,response,error in
        
        // Ensure that we've got a valid http response
        guard let httpResponse = response as? HTTPURLResponse, let _ = data
            else {
                print("error: not a valid http response")
                return
        }
        
        // Make decisions based on the httpResponse Status Code
        switch (httpResponse.statusCode) {
        // If the httpResponse Status Code is 200, it means the request was successful
        case 200:
            
            // We get the chatAuthToken necessary for the chat login
            let chatAuthToken = httpResponse.allHeaderFields["Chat-Auth-Token"] as? String ?? ""
            
            // We set the memberID as a value to the LoggedInUserUID key
            // This is needed so that the chat code knows that when you send a msg it's originating from you
            UserDefaults.standard.set(memberID, forKey: "LoggedInUserUID")
            
            let appSettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: Contants.chatRegion).build()
            CometChat.init(appId: AuthenticationDict?["APP_ID"] as! String, appSettings: appSettings, onSuccess: { (Success) in
               print("initialization Success: \(Success)")
            }) { (error) in
               print("Initialization Error \(error.errorDescription)")
            }
            
            if Contants.communityMemberChatLoggedIn == false {
                // Attempt to login to chat with the chatAuthToken
                CometChat.login(authToken: chatAuthToken, onSuccess:
                    {(Success) in
                        print("Login Success: \(Success)")
                        
                        // Toggle the logged in status
                        Contants.communityMemberChatLoggedIn.toggle()
                        
                        // Signal to the semaphore that the login is done
                        semaphore.signal()
                })
                {(error) in
                    print("Login Error \(error.errorDescription)")
                    
                    // Signal to the semaphore that the login is done
                    semaphore.signal()
                }
            } else {
                // Signal to the semaphore right away when the community member is logged in
                semaphore.signal()
            }
            

            
        // If the httpResponse Status Code is any other code, it means the request was not successful
        default:
            
            // Signal to the semaphore that the login is done even though it failed
            semaphore.signal()
            break
        }
    }
    // Resume the data task presumably for graceful completition
    dataTask.resume()
    
    // Wait for a few seconds to leave enough time for login
    _ = semaphore.wait(timeout: .now() + 14)
    
    return Contants.communityMemberChatLoggedIn
}

// Language localisation related code below

var bundleKey: UInt8 = 0

class AnyLanguageBundle: Bundle {
    
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
                
                return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    
    class func setLanguage(_ language: String) {
        
        defer {
            
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey,    Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
