//
//  UIViewController+Extentions.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/30/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import CommunityKit
import NVActivityIndicatorView
import FlowKit

extension ErrorDisplayable where Self: UIViewController {
    
    func displayError(title: String, error: Error) {
        presentError(controller: self, title: title, error: error)
    }
    
}

extension ViewControllerProvider where Self: UIViewController {
    var viewController: UIViewController {
        return self
    }
}

class SelectorWrapper: NSObject {
    
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    @objc func doAction() {
        action()
    }
    
}

extension KeyboardDismissable where Self: UIViewController {
    
    /// Function that sets up keyboard dismiss on tap outside active fields
    ///
    /// - Returns: An object that holds a selector. IMPORTANT: be sure to take reference for the returned object for dismiss to work
    func setupKeyboardDismissRecognizer() -> SelectorWrapper {
        let wrapper = SelectorWrapper(action: { [weak self] in
            self?.view.endEditing(true)
        })
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(
            target: wrapper,
            action: #selector(wrapper.doAction)
        )
        self.view.addGestureRecognizer(tapRecognizer)
        
        return wrapper
    }
    
}

extension LoadingIndicatorDisplayable where Self: UIViewController & ActivityViewProvider {
    
    func setLoadingIndicatorVisible(_ visible: Bool) {
        if visible {
            self.activity?.startAnimating()
        } else {
            self.activity?.stopAnimating()
        }
    }
    
}
