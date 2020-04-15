//
//  ViewMember.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 4/1/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit
import CometChatPro
import CachingExtension
import XLPagerTabStrip

class ViewMemberScreen: UIViewController, ViewCurrentMemberViewProtocol, ActivityViewProvider {
    var presenter: WeakWrapper<ViewCurrentMemberPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    
    let labelProperName = UILabel()
    let labelUsername = UILabel()
    let labelEmail = UILabel()
    let logoutButton = Button.build(style: .solid)
    let profilePictureImageView = UIImageView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)

        let headerImageView = UIImageView()
        headerImageView.contentMode =  UIView.ContentMode.scaleAspectFill
        headerImageView.clipsToBounds = false
        headerImageView.image = UIImage(named: "profile-background.jpg")
        headerImageView.clipsToBounds = true
        headerImageView.alpha = 0.6
        container.addSubview(headerImageView)
        
        let labelTitle = UILabel()
        labelTitle.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelTitle.textAlignment = .center
        labelTitle.sizeToFit()
        labelTitle.font = Fonts.font(of: 20.0, weight: .bold)
        container.addSubview(labelTitle)
        
        var avatarVariableSize = 170
        if device(is: .iPhone5) {
            avatarVariableSize = 130
        }
        profilePictureImageView.frame = CGRect(x:0, y:0, width: avatarVariableSize, height: avatarVariableSize)
        profilePictureImageView.contentMode =  UIView.ContentMode.scaleAspectFit
        profilePictureImageView.layer.borderWidth = 1
        profilePictureImageView.layer.masksToBounds = false
        profilePictureImageView.layer.borderColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor).cgColor
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.height/2
        profilePictureImageView.clipsToBounds = true
        container.addSubview(profilePictureImageView)
        
        labelProperName.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelProperName.textAlignment = .left
        labelProperName.adjustsFontSizeToFitWidth = true;
        labelProperName.font = Fonts.font(of: 18.0, weight: .bold)
        container.addSubview(labelProperName)
        
        labelUsername.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelUsername.textAlignment = .left
        labelUsername.adjustsFontSizeToFitWidth = true;
        labelUsername.font = Fonts.font(of: 16.0, weight: .regular)
        container.addSubview(labelUsername)
        
        let labelEmailTitle = UILabel()
        labelEmailTitle.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelEmailTitle.textAlignment = .left
        labelEmailTitle.sizeToFit()
        labelEmailTitle.font = Fonts.font(of: 19.0, weight: .bold)
        labelEmailTitle.text = "Email"
        container.addSubview(labelEmailTitle)
        
        labelEmail.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelEmail.textAlignment = .left
        labelEmail.adjustsFontSizeToFitWidth = true;
        labelEmail.font = Fonts.font(of: 16.0, weight: .regular)
        container.addSubview(labelEmail)
        
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.setTitle("Log out", for: .normal)
        container.addSubview(logoutButton)

        headerImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.top).offset(200)
        }
        profilePictureImageView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(avatarVariableSize)
            make.width.equalTo(avatarVariableSize)
            make.left.equalTo(container.snp.left).offset(10)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.top).offset(280)
        }
        labelTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(container.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalTo(container.snp.centerX)
            make.left.equalTo(container).offset(20)
            make.right.equalTo(container).offset(-20)
        }
        labelProperName.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(headerImageView.snp.bottom).offset(10)
            make.left.equalTo(profilePictureImageView.snp.right).offset(10)
            make.right.equalTo(container).offset(-20)
        }
        labelUsername.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(labelProperName)
            make.right.equalTo(container).offset(-20)
            make.bottom.equalTo(labelProperName.safeAreaLayoutGuide.snp.bottom).offset(23)
        }
        labelEmailTitle.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(labelUsername.safeAreaLayoutGuide.snp.bottom).offset(70)
        }
        labelEmail.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(labelEmailTitle.safeAreaLayoutGuide.snp.bottom).offset(25)
        }
        logoutButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    func update(with member: Member) {
        labelEmail.text = String(describing: member.emailAddress)
        labelUsername.text = String(describing: member.username)
        labelProperName.text = String(describing: member.properName)
        profilePictureImageView.image = member.profilePicture?.picture ?? UIImage(named: "avatar-icon")
    }
    
    @objc func logout(sender: UIButton!) {
        
        CachingExtension.clearCacheData()
        CachingExtension.syncMessages()
        Contants.communityMemberChatLoggedIn = false
        CometChat.logout(onSuccess: { (response) in
            
            print("Logout successfully.")
            
        }) { (error) in
            
            print("logout failed with error: " + error.errorDescription);
        }
        
        presenter.wrapped?.logout()
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}


extension ViewMemberScreen: IndicatorInfoProvider {
 func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
   return IndicatorInfo(title: "Profile")
 }
}
