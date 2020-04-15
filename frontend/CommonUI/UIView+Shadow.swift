//
//  UIView+Shadow.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/11/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation

extension UIView {
    
    func addShadow(offset: CGSize, opacity: Float, radius: CGFloat) {
        layer.shadowOffset = offset
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
}
