//
//  ActivityIndicator.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 4/17/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

struct ActivityIndicator {
    
    static func build(in container: UIView, size: CGFloat = 40.0) -> NVActivityIndicatorView {
        let activity = NVActivityIndicatorView(frame: CGRect(x: (container.frame.width - size)/2, y: (container.frame.height - size)/2, width: size, height: size),type: NVActivityIndicatorType.lineSpinFadeLoader, color: UIColor.gray)
        container.addSubview(activity)
        return activity
    }
    
}
