//
//  WalletLandingScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/22/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import WalletKit
import FlowKit

class WalletLandingScreen: UIViewController, WalletLandingViewProtocol {
    
    var presenter: WeakWrapper<WalletLandingPresenterProtocol> = WeakWrapper()
    
    @IBAction func createWalletTapped(_ sender: Any) {
        presenter.wrapped?.goToMnemonicCreate()
    }
    
    @IBAction func restoreWalletTapped(_ sender: Any) {
        presenter.wrapped?.goToMnemonicResore()
    }
    
}
