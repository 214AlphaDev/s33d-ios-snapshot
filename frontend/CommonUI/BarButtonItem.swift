//
//  BarButtonItem.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/14/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

struct BarButtonItem {
    
    static func configured(item: UIBarButtonItem) -> UIBarButtonItem {
        item.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.font(of: 16, weight: .light)], for: .normal)
        item.setTitleTextAttributes([
            NSAttributedString.Key.font: Fonts.font(of: 16, weight: .light),
            NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.globalBarButtonBackgroundColor)]
            , for: .disabled)
        item.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.font(of: 16, weight: .light)], for: .highlighted)
        
        return item
    }
    
}
