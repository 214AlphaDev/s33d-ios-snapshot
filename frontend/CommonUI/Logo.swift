//
//  Logo.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/31/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit

struct Logo {
    
    @discardableResult static func build(in container: UIView, height: Float, bottomOffset: Float) -> UIView {
        let logo_image = UIImage(named: Contants.globalLogo)
        let logoImageView = UIImageView()
        logoImageView.contentMode =  UIView.ContentMode.scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.image = logo_image
        container.addSubview(logoImageView)
        
        var heightVariableSize = height
        var bottomVariableSize = bottomOffset
        if device(is: .iPhone5) {
            heightVariableSize = heightVariableSize - 80
            bottomVariableSize = bottomVariableSize - 100
        }
        
        logoImageView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(heightVariableSize)
            make.left.equalTo(container).offset(Contants.globalLogoLeftOffset)
            make.right.equalTo(container).offset(Contants.globalLogoRightOffset)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.top).offset(bottomVariableSize)
        }
        
        return logoImageView
    }
    
}
