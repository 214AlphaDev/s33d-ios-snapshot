//
//  ViewController.swift
//  GetStreamActivityFeedDemo
//
//  Created by Alexey Bukhtin on 20/03/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import UIKit
import GetStream
import GetStreamActivityFeed
import XLPagerTabStrip
import FlowKit

class FeedPlaceholderScreen: FlatFeedViewController<GetStreamActivityFeed.Activity>, Presenter {
    
    var window: UIWindow?
    
    let textToolBar = TextToolBar.make()
    
    override func viewDidLoad() {
       
   
        if let feedId = FeedId(feedSlug: Contants.feedSlug) {
            let timelineFlatFeed = Client.shared.flatFeed(feedId)
            
            // Comment out the line below to enable reactions once development is done
            // presenter = FlatFeedPresenter<GetStreamActivityFeed.Activity>(flatFeed: timelineFlatFeed, reactionTypes: [.comments, .reposts, .likes])
            presenter = FlatFeedPresenter<GetStreamActivityFeed.Activity>(flatFeed: timelineFlatFeed, reactionTypes: [.likes, .comments])
        }
        
        if Contants.communityMemberFeedLoggedIn == false {
            // Setup Stream user.
            Client.shared.getCurrentUser(typeOf: GetStreamActivityFeed.User.self) { result in
                // Current user is ready. Load timeline feed.
                if result.error == nil {
                    let viewController = self.window?.rootViewController as? FeedPlaceholderScreen
                    print("Feed Login Success")
                
                    // Toggle the logged in status
                    Contants.communityMemberFeedLoggedIn.toggle()
                
                    viewController?.reloadData()
                } else {
                    print("Feed Login Error")
                }
            } // Client.shared.getCurrentUser
        } // if Contants.communityMemberFeedLoggedIn
        
        super.viewDidLoad()
        setupTextToolBar()
        subscribeForUpdates()
    }
    
    func setupTextToolBar() {
        textToolBar.addToSuperview(view, placeholderText: "Share something...")
        textToolBar.textView.textColor = UIColor.black
        textToolBar.textView.tintColor = UIColor.gray
        // Enable URL unfurling.
        // textToolBar.linksDetectorEnabled = true
        // Delete the line below to unfurl links once development of the feature is done
        textToolBar.linksDetectorEnabled = false
        
        // Enable image picker.
        textToolBar.enableImagePicking(with: self)
        textToolBar.sendButton.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
    }
    
    @objc func save(_ sender: UIButton) {
        // Hide the keyboard.
        view.endEditing(true)
        
        // Check that entered text is not empty
        // and get the current user, it shouldn’t be nil.
        if textToolBar.isValidContent, let presenter = presenter {
            textToolBar.addActivity(to: presenter.flatFeed) { result in
                print(result)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // Create a detail view controller.
            let detailViewController = DetailViewController<GetStreamActivityFeed.Activity>()
            // Set the activity presenter from the selected cell.
            detailViewController.activityPresenter = activityPresenter(in: indexPath.section)
            // Set sections we want to show the activity itself and comments.
            //detailViewController.sections = [.activity, .comments]
            detailViewController.sections = [.activity, .likes, .comments]
            // Present the detail view controller with UINavigationController
            // to use the navigation bar to return back.
            present(UINavigationController(rootViewController: detailViewController), animated: true)
        } else {
            // Keep the default behaviour for over rows in the table view.
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
}

func FeedLogin(memberID:String, rawAccessToken:String, URLString:String) -> Bool {
    
    if memberID == "" {
        return Contants.communityMemberFeedLoggedIn
    }
    
    // Create a semaphore for syncronous task
    let semaphore = DispatchSemaphore(value: 0)
    
    // Create URLSession for the Feed-Auth-Token Request
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
    
    // Start the dataTask which upon successful completition would provide us with the Feed-Auth-Token
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
            
            // We get the feedAuthToken necessary for the feed login
            let feedAuthToken = httpResponse.allHeaderFields["Feed-Auth-Token"] as? String ?? ""
            
            if Contants.communityMemberFeedLoggedIn == false {
                // Setup a timeline feed presenter.
            
                Client.config = .init(apiKey: Contants.feedKey, appId: Contants.feedAppID, token: feedAuthToken)
                // Signal to the semaphore right away when the community member is logged in
                semaphore.signal()
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
    
    return Contants.communityMemberFeedLoggedIn
}

extension FeedPlaceholderScreen: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "yOur story")
    }
    
}
