//
//  Button.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/31/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit

struct Button {
    
    enum Style {
        case transparent
        case solid
        case icon(UIImage)
    }
    
    static func build(style: Style) -> UIButton {
        let button = UIButton(type: .custom)
        switch style {
        case .solid:
            button.backgroundColor = UIColor.init(hexFromString: Contants.globalSolidButtonBackgroundColor)
            button.normalStateBackgroundColor = UIColor.init(hexFromString: Contants.globalSolidButtonNormalStateBackgroundColor)
            button.selectedStateBackgroundColor = UIColor.init(hexFromString: Contants.globalSolidButtonSelectedStateBackgroundColor)
            button.highlightedStateBackgroundColor = UIColor.init(hexFromString: Contants.globalSolidButtonHighlightedStateBackgroundColor)
            button.disabledStateBackgroundColor = UIColor.init(hexFromString: Contants.globalSolidButtonDisabledStateBackgroundColor)
            button.layer.cornerRadius = 5
            button.setTitleColor(UIColor.init(hexFromString: Contants.globalSolidButtonTitleColor), for: .normal)
            button.titleLabel?.font = Fonts.font(of: 20, weight: .medium)
            button.snp.makeConstraints { make in
                make.height.equalTo(52)
            }
        case .transparent:
            button.backgroundColor = UIColor.clear
            button.layer.cornerRadius = 5
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.init(hexFromString: Contants.globalTransparentButtonBorderColor).cgColor
            button.setTitleColor(UIColor.init(hexFromString: Contants.globalTransparentButtonTitleColor), for: .normal)
            button.setTitleColor(UIColor.init(hexFromString: Contants.globalTransparentButtonHighlightedColor), for: .highlighted)
            button.titleLabel?.font = Fonts.font(of: 20, weight: .medium)
            button.snp.makeConstraints { make in
                make.height.equalTo(52)
            }
        case .icon(let image):
            button.setImage(image, for: .normal)
            button.backgroundColor = UIColor.clear
        }
        
        return button
    }
    
}
