//
//  LoadingFlow.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/12/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import FlowKit

class LoadingFlow: BaseFlow {
    
    let screen = LoadingScreen()

    override func rootViewController() -> UIViewController {
        return screen
    }
    
}
