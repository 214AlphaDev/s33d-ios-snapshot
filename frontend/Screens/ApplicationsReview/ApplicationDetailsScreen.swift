//
//  ApplicationDetailsScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/25/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit

class ApplicationDetailsScreen: UIViewController, KeyboardDismissable, ApplicationDetailsViewProtocol, ActivityViewProvider {
    var presenter: WeakWrapper<ApplicationDetailsPresenterProtocol> = WeakWrapper()
    var keyboardDismissAction: SelectorWrapper?
    var activity: NVActivityIndicatorView?
    
    let profilePictureView = UIImageView(frame: CGRect(x:0, y:0, width: 170, height: 170))
    let labelProperName = UILabel()
    let labelUsername = UILabel()
    let labelEmail = UILabel()
    let labelApplicationText = UITextView()
    let aceptButton = Button.build(style: .solid)
    let rejectButton = Button.build(style: .transparent)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
        keyboardDismissAction = setupKeyboardDismissRecognizer()
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)

        profilePictureView.contentMode =  UIView.ContentMode.scaleAspectFit
        profilePictureView.layer.borderWidth = 1
        profilePictureView.layer.masksToBounds = false
        profilePictureView.layer.borderColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor).cgColor
        profilePictureView.layer.cornerRadius = profilePictureView.frame.height/2
        profilePictureView.clipsToBounds = true
        container.addSubview(profilePictureView)
        
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
        
        labelEmail.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelEmail.textAlignment = .left
        labelEmail.adjustsFontSizeToFitWidth = true;
        labelEmail.font = Fonts.font(of: 16.0, weight: .regular)
        container.addSubview(labelEmail)
        
        labelApplicationText.textAlignment = NSTextAlignment.left
        labelApplicationText.backgroundColor = nil
        labelApplicationText.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelApplicationText.font = Fonts.font(of: 16, weight: .bold)
        labelApplicationText.isEditable = false
        container.addSubview(labelApplicationText)
        
        aceptButton.addTarget(self, action: #selector(acceptMember), for: .touchUpInside)
        aceptButton.setTitle("Approve", for: .normal)
        container.addSubview(aceptButton)
        
        rejectButton.addTarget(self, action: #selector(rejectMember), for: .touchUpInside)
        rejectButton.setTitle("Reject", for: .normal)
        container.addSubview(rejectButton)
        
        profilePictureView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(170)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.top).offset(190)
        }
        labelProperName.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(profilePictureView.safeAreaLayoutGuide.snp.bottom).offset(70)
        }
        labelUsername.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(labelProperName.safeAreaLayoutGuide.snp.bottom).offset(30)
        }
        labelEmail.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(labelUsername.safeAreaLayoutGuide.snp.bottom).offset(30)
        }
        labelApplicationText.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(27)
            make.right.equalTo(container).offset(-27)
            make.top.equalTo(labelEmail.safeAreaLayoutGuide.snp.bottom).offset(10)
            make.bottom.equalTo(aceptButton.safeAreaLayoutGuide.snp.top).offset(-5)
        }
        if device(is: .iPhone5) {
            aceptButton.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(container).offset(30)
                make.right.equalTo(profilePictureView.snp.centerX).offset(-5)
                make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
            }
            rejectButton.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(profilePictureView.snp.centerX).offset(5)
                make.right.equalTo(container).offset(-30)
                make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
            }
        } else {
            aceptButton.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(container).offset(30)
                make.right.equalTo(container).offset(-30)
                make.bottom.equalTo(rejectButton.snp.top).offset(-25)
            }
            rejectButton.snp.makeConstraints { (make) -> Void in
                make.left.equalTo(container).offset(30)
                make.right.equalTo(container).offset(-30)
                make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
            }
        }
    }
    
    @objc func acceptMember(sender:UIButton!) {
        presenter.wrapped?.approveApplication()
    }
    
    @objc func rejectMember(sender:UIButton!) {
        selectReasonForRejection(controller: self)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func showApplication(_ applicationViewData: MemberApplicationViewData) {
        labelProperName.text = applicationViewData.member.properName.firstName + " " + applicationViewData.member.properName.lastName
        labelUsername.text = applicationViewData.member.username.username
        labelEmail.text = applicationViewData.member.emailAddress.emailAddress
        labelApplicationText.text = applicationViewData.application.applicationText.applicationText
        profilePictureView.image = applicationViewData.member.profilePicture?.picture ?? UIImage(named: "camera-icon")
    }
    
    func selectReasonForRejection(controller: UIViewController) {
        let alert = UIAlertController(title: Contants.applicationRejectionScreenTitle, message: "Please select a reason for Rejection:", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Bad profile picture", style: .default, handler: { (_) in
            self.presenter.wrapped?.rejectApplication(reason: "Bad profile picture")
        }))
        alert.addAction(UIAlertAction(title: "False information", style: .default, handler: { (_) in
            self.presenter.wrapped?.rejectApplication(reason: "False information")
        }))
        alert.addAction(UIAlertAction(title: "Incomplete Information", style: .default, handler: { (_) in
            self.presenter.wrapped?.rejectApplication(reason: "Incomplete Information")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        self.present(alert, animated: true, completion: {
        })
    }
}
