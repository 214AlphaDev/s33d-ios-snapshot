//
//  AppDelegate.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 2/12/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var root: Root!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow()
        self.window = window
        window.makeKeyAndVisible()
        root = Root(window: window)
        root.runApplication()

        return true
    }

}

