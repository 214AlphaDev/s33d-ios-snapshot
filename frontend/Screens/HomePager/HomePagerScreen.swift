//
//  HomePagerScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/28/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import XLPagerTabStrip

class HomePagerScreen: ButtonBarPagerTabStripViewController {
    
    override func viewDidLoad() {
        // Customization should be done before calling self
        settings.style.buttonBarItemFont = Fonts.font(of: 18, weight: .medium)
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        settings.style.selectedBarHeight = 2
        settings.style.buttonBarItemLeftRightMargin = 26
        
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return datasource?.viewControllers(for: pagerTabStripController) ?? []
    }
    
}
