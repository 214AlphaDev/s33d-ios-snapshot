//
//  LineSeparator.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/13/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

struct LineSeparator {
    
    static func build(in container: UIView) -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)
        container.addSubview(separator)
        
        separator.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        return separator
    }
    
}
