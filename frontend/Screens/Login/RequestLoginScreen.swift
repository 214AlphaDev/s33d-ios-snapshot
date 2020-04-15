//
//  RequestLoginScreen.swift
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

class RequestLoginScreen : UIViewController, RequestLoginViewProtocol, UITextFieldDelegate, KeyboardDismissable, ActivityViewProvider {
    
    let getCodeButton = Button.build(style: .solid)
    let inputEmail = UITextField()
    var keyboardDismissAction: SelectorWrapper?
    var activity: NVActivityIndicatorView?
    var presenter: WeakWrapper<RequestLoginPresenterProtocol> = WeakWrapper()
    
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
        Logo.build(in: container, height: 200, bottomOffset: 250)
        
        activity = ActivityIndicator.build(in: container)
        
        inputEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.requestLoginScreenForegroundColor)])
        inputEmail.borderStyle = UITextField.BorderStyle.none
        inputEmail.backgroundColor = nil
        inputEmail.textColor = UIColor.init(hexFromString: Contants.requestLoginScreenTextColor)
        inputEmail.keyboardType = UIKeyboardType.emailAddress
        inputEmail.autocapitalizationType = UITextAutocapitalizationType.none
        inputEmail.autocorrectionType = UITextAutocorrectionType.no
        inputEmail.delegate = self
        inputEmail.background = UIImage(named: Contants.globalLine)
        container.addSubview(inputEmail)
        
        getCodeButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
        getCodeButton.setTitle("Get Verification Code", for: .normal)
        container.addSubview(getCodeButton)
        
        inputEmail.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
        }
        getCodeButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }

    @objc func getCode(sender:UIButton!) {
        presenter.wrapped?.requestConfirmationCode()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: RequestLoginViewProtocol
    
    func setRequestConfirmationCodeButtonEnabled(_ enabled: Bool) {
        getCodeButton.isEnabled = enabled
    }
    
    func cleanUp() {
        inputEmail.text = ""
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        presenter.wrapped?.setEmailAddress(inputEmail.text ?? "")
        return true
    }
    
}
