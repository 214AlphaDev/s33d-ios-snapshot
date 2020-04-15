//
//  LandingPageScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/24/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import FlowKit
import PopMenu
import KeychainAccess

class LandingPageScreen: UIViewController, LandingPageViewProtocol {
    
    var presenter: WeakWrapper<LandingPagePresenterProtocol> = WeakWrapper()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        let menuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuTapped))
        menuItem.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        navigationItem.rightBarButtonItem = BarButtonItem.configured(item: menuItem)
        
        Background.build(in: container)
        Logo.build(in: container, height: 200, bottomOffset: 250)
        
        let signUpButton = Button.build(style: .solid)
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
        signUpButton.setTitle("Sign up", for: .normal)
        container.addSubview(signUpButton)
        
        let loginButton = Button.build(style: .transparent)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.setTitle("Login", for: .normal)
        container.addSubview(loginButton)
        
        signUpButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(loginButton.safeAreaLayoutGuide.snp.top).offset(-25)
        }
        loginButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-60)
        }
    }
    
    
    @objc func login(sender:UIButton!) {
        presenter.wrapped?.goToLogin()
    }
    
    @objc func signUp(sender:UIButton!) {
        presenter.wrapped?.goToSignUp()
    }
    
    @objc func menuTapped(sender: AnyObject?) {
        var actions: [PopMenuAction] = []
        
        let alohaAction = PopMenuDefaultAction(title: "Aloha", color: .white) { _ in
            self.dismiss(animated: true, completion: {
                Contants.baseURL = Contants.backendURL
                Contants.communityBackendURL = Contants.baseURL.appendingPathComponent("/community")
                Contants.wishlistBackendURL = Contants.baseURL.appendingPathComponent("/wishlist")
                Contants.inventoryBackendURL = Contants.baseURL.appendingPathComponent("/inventory")
                Contants.inventoryBackupBackendURL = Contants.baseURL.appendingPathComponent("/inventory-backup")
                Contants.marketplaceBackendURL = Contants.baseURL.appendingPathComponent("/marketplace")
                Contants.communityChatTokenURL = Contants.baseURL.appendingPathComponent("/chat/new-token")
                Contants.communityFeedTokenURL = Contants.baseURL.appendingPathComponent("/feed/new-token")
                Contants.loginBackend = LoginBackend(url: Contants.communityBackendURL)
                Contants.loginService = LoginService(accessMaterialRepository: Contants.accessMaterialRepository, loginBackend:  Contants.loginBackend)
                Contants.applicationRoot = ApplicationRoot(loginService: Contants.loginService, loggedOutFlow: Root(window: Contants.window).buildLoggedOutFlow(loginService: Contants.loginService), loggedInFlowFactory: Root(window: Contants.window).buildLoggedInFlowFactory(keychain: Contants.keychain), window: Contants.window)
                let window = UIWindow()
                window.makeKeyAndVisible()
                let root = Root(window: window)
                //UIApplication.shared.keyWindow?.rootViewController = self.tabBarController
                root.runApplication()
            })
        }
        actions.append(alohaAction)
        
        
        let londonAction = PopMenuDefaultAction(title: "London", color: .white) { _ in
            self.dismiss(animated: true, completion: {
                Contants.baseURL = Contants.alternativeURL
                Contants.communityBackendURL = Contants.baseURL.appendingPathComponent("/community")
                Contants.wishlistBackendURL = Contants.baseURL.appendingPathComponent("/wishlist")
                Contants.inventoryBackendURL = Contants.baseURL.appendingPathComponent("/inventory")
                Contants.inventoryBackupBackendURL = Contants.baseURL.appendingPathComponent("/inventory-backup")
                Contants.marketplaceBackendURL = Contants.baseURL.appendingPathComponent("/marketplace")
                Contants.communityChatTokenURL = Contants.baseURL.appendingPathComponent("/chat/new-token")
                Contants.communityFeedTokenURL = Contants.baseURL.appendingPathComponent("/feed/new-token")
                Contants.loginBackend = LoginBackend(url: Contants.communityBackendURL)
                Contants.loginService = LoginService(accessMaterialRepository: Contants.accessMaterialRepository, loginBackend:  Contants.loginBackend)
                Contants.applicationRoot = ApplicationRoot(loginService: Contants.loginService, loggedOutFlow: Root(window: Contants.window).buildLoggedOutFlow(loginService: Contants.loginService), loggedInFlowFactory: Root(window: Contants.window).buildLoggedInFlowFactory(keychain: Contants.keychain), window: Contants.window)
                let window = UIWindow()
                window.makeKeyAndVisible()
                let root = Root(window: window)
                //UIApplication.shared.keyWindow?.rootViewController = self.tabBarController
                root.runApplication()
                
            })
        }
        actions.append(londonAction)
        
        let menu = PopMenuViewController(sourceView: sender, actions: actions)
        menu.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(r: 49, g: 69, b: 92))
        menu.appearance.popMenuCornerRadius = 10
        menu.appearance.popMenuItemSeparator = .fill(.white)
        menu.appearance.popMenuFont = Fonts.font(of: 16, weight: .regular)
        
        present(menu, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}
