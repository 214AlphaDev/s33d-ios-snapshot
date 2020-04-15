//
//  Fonts.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/13/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation

struct Fonts {
    
    static func font(of size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "AvenirNext-Regular", size: size)!
        case .medium:
            return UIFont(name: "AvenirNext-Medium", size: size)!
        case .bold:
            return UIFont(name: "AvenirNext-DemiBold", size: size)!
        case .light:
            return UIFont(name: "Avenir-Light", size: size)!
        default:
            return UIFont(name: "AvenirNext-Regular", size: size)!
        }
    }
    
}
