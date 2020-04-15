//
//  SendMemberVerificationApplicationScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/25/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import CommunityKit
import FlowKit

class SendMemberVerificationApplicationScreen: UIViewController, SendMemberVerificationViewProtocol, KeyboardDismissable, UITextViewDelegate, ActivityViewProvider {
    
    let sendApplicationButton = Button.build(style: .solid)
    var presenter: WeakWrapper<SendMemberVerificationPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var logoView = UIImageView()
    
    var keyboardDismissAction: SelectorWrapper?
    
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
        logoView = Logo.build(in: container, height: 170, bottomOffset: 210) as! UIImageView
        
        activity = ActivityIndicator.build(in: container)
        
        let labelApplicationText = UILabel()
        labelApplicationText.textColor = .lightGray
        labelApplicationText.textAlignment = .left
        labelApplicationText.font = UIFont.preferredFont(forTextStyle: .headline)
        labelApplicationText.adjustsFontSizeToFitWidth = true
        labelApplicationText.text = Contants.applicationSubmitText
        container.addSubview(labelApplicationText)
        
        let inputApplicationText = UITextView()
        inputApplicationText.textAlignment = NSTextAlignment.left
        inputApplicationText.backgroundColor = nil
        inputApplicationText.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        inputApplicationText.font = Fonts.font(of: 16, weight: .bold)
        inputApplicationText.keyboardType = UIKeyboardType.default
        inputApplicationText.delegate = self
        container.addSubview(inputApplicationText)
        
        let lineImageView = UIImageView()
        lineImageView.contentMode =  UIView.ContentMode.scaleToFill
        lineImageView.clipsToBounds = true
        lineImageView.image = UIImage(named: Contants.globalLine)
        container.addSubview(lineImageView)
        
        
        sendApplicationButton.addTarget(self, action: #selector(sendApplication), for: .touchUpInside)
        sendApplicationButton.setTitle("Submit", for: .normal)
        container.addSubview(sendApplicationButton)
        
        labelApplicationText.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.height.equalTo(35)
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.top.equalTo(logoView.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        inputApplicationText.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.top.equalTo(logoView.safeAreaLayoutGuide.snp.bottom).offset(70)
        }
        lineImageView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(20)
            make.left.equalTo(inputApplicationText)
            make.right.equalTo(inputApplicationText)
            make.top.equalTo(inputApplicationText.snp.top).offset(190)
        }
        sendApplicationButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    @objc func sendApplication(sender:UIButton!) {
        presenter.wrapped?.submit()
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        presenter.wrapped?.setApplicationText(textView.text)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if device(is: .iPhone5) {
            self.animateLogoView(height: 0, offset: 10)
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if device(is: .iPhone5) {
            self.animateLogoView(height: 90, offset: 110)
        }
        return true
    }
    
    func animateLogoView(height: Float, offset: Float) {
        UIView.animate(withDuration: 0.3) {
            self.logoView.snp.remakeConstraints { (make) -> Void in
                make.height.equalTo(height)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(offset)
            }
            self.logoView.superview?.layoutIfNeeded()
        }
    }
    
    // MARK: SendMemberVerificationViewProtocol
    
    func setSubmitButtonEnabled(_ enabled: Bool) {
        sendApplicationButton.isEnabled = enabled
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
