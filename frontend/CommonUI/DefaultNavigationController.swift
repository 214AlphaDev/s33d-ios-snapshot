//
//  DefaultNavigationController.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/30/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

final class DefaultNavigationController: UINavigationController {
    
    convenience init() {
        self.init(rootViewController: UIViewController())
        // Transparent Navigation Bar
        
        DefaultNavigationController.configureNavigationBar(navigationBar)
    }
    
    static func configureNavigationBar(_ navigationBar: UINavigationBar) {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = .clear
        navigationBar.isTranslucent = true
        navigationBar.tintColor = UIColor.init(hexFromString: Contants.globalNavigationBarTintColor)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.globalNavigationBarTextAttributeColor), NSAttributedString.Key.font: Fonts.font(of: 22, weight: .bold)]
        
        navigationBar.titleTextAttributes = textAttributes
        navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationBar.backIndicatorImage = UIImage(named: "back_arrow")
        navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "back_arrow")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = UIColor.init(hexFromString: Contants.globalNavigationBarBackButtonTintColor)
        
        topViewController?.navigationItem.backBarButtonItem = backBarButtonItem
        super.pushViewController(viewController, animated: true)
    }
    
}
