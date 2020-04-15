//
//  LoginVerificationCodeScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/21/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit
import CometChatPro
import CachingExtension

class LoginVerificationCodeScreen : UIViewController, LoginViewProtocol, KeyboardDismissable, UITextFieldDelegate, ActivityViewProvider {
    
    let verifyButton = Button.build(style: .solid)
    let inputCode = UITextField()
    var activity: NVActivityIndicatorView?
    
    var keyboardDismissAction: SelectorWrapper?
    
    var presenter: WeakWrapper<LoginPresenterProtocol> = WeakWrapper()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If a community member needs to login into the app we want to ensure that he is logged out of chat
        CachingExtension.clearCacheData()
        CachingExtension.syncMessages()
        Contants.communityMemberChatLoggedIn = false
        CometChat.logout(onSuccess: { (response) in
            
            print("Logout successfully.")
            
        }) { (error) in
            
            print("logout failed with error: " + error.errorDescription);
        }
        
        createUI(in: view)
        keyboardDismissAction = setupKeyboardDismissRecognizer()
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        Logo.build(in: container, height: 200, bottomOffset: 250)
        
        activity = ActivityIndicator.build(in: container)
        
        inputCode.attributedPlaceholder = NSAttributedString(string: "Verification CODE sent by email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        inputCode.borderStyle = UITextField.BorderStyle.none
        inputCode.backgroundColor = nil
        inputCode.textColor = UIColor.init(hexFromString: Contants.requestLoginScreenTextColor)
        inputCode.keyboardType = UIKeyboardType.numberPad
        inputCode.isSecureTextEntry = true
        inputCode.delegate = self
        inputCode.background = UIImage(named: Contants.globalLine)
        container.addSubview(inputCode)
        
        let resendCodeButton = UIButton()
        resendCodeButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
        resendCodeButton.backgroundColor = nil
        resendCodeButton.setTitle("Resend CODE", for: .normal)
        resendCodeButton.titleLabel?.font = .systemFont(ofSize: 14)
        container.addSubview(resendCodeButton)
        
        verifyButton.addTarget(self, action: #selector(verify), for: .touchUpInside)
        verifyButton.setTitle("Verify Code", for: .normal)
        container.addSubview(verifyButton)
        
        inputCode.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
        }
        resendCodeButton.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.bottom.equalTo(inputCode.safeAreaLayoutGuide.snp.bottom).offset(45)
        }
        verifyButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }

    @objc func resendCode(sender: UIButton!) {
        presenter.wrapped?.resendConfirmationCode()
    }
    
    @objc func verify(sender: UIButton!) {
        presenter.wrapped?.confirm()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func cleanUp() {
        inputCode.text = ""
    }
    
    // MARK: LoginViewProtocol
    
    func setConfirmButtonEnabled(_ enabled: Bool) {
        verifyButton.isEnabled = enabled
    }
    
    func showConfirmationCodeSuccessfulSend() {
        presentAlert(controller: self, title: "Success", message: "Confirmation code was sent")
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        presenter.wrapped?.setConfirmationCode(inputCode.text ?? "")
        return true
    }
}
