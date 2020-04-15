//
//  ActivityViewProvider.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 4/18/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

protocol ActivityViewProvider {
    
    var activity: NVActivityIndicatorView? { get }
    
}
