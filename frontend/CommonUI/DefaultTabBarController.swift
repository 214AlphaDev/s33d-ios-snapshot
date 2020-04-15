//
//  DefaultTabBarController.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/31/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

final class DefaultTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.tabBar.isTranslucent = Contants.globalTabBarIsTranslucent
        let barTintColor = Contants.globalTabBarTintColor
        if barTintColor.count > 5 {
            self.tabBar.barTintColor = UIColor.init(hexFromString: barTintColor)
        }
        self.tabBar.unselectedItemTintColor = UIColor.init(hexFromString: Contants.globalTabBarUnselectedItemTintColor)
        self.tabBar.tintColor = UIColor(r: 248, g: 159, b: 61)
    }
}

