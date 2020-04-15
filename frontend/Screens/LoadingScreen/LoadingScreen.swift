//
//  LoadingScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/12/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import FlowKit
import NVActivityIndicatorView

class LoadingScreen: UIViewController, LoadingIndicatorDisplayable, ActivityViewProvider {
    
    var activity: NVActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setLoadingIndicatorVisible(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setLoadingIndicatorVisible(true)
    }
    
}
