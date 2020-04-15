//
//  Background.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/30/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit

struct Background {
    
    static func build(in container: UIView) {
        let background = UIView()
        
        background.backgroundColor = UIColor.init(hexFromString: Contants.globalBackgroundColor)
        container.addSubview(background)
        container.sendSubviewToBack(background)
        
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
