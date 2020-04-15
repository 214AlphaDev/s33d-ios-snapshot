//
//  ChatPlaceholderScreen.swift
//  214-demo-community
//
//  Created by Andrii Selivanov on 8/16/19.
//  Copyright © 2019 214alpha. All rights reserved.
//

import Foundation
import FlowKit

class ChatPlaceholderScreen: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        
        Background.build(in: container)
        
    }
}
