//
//  SignUpScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/24/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit

class SignUpScreen : UIViewController, ImagePickerControllerDelegate, SignUpViewProtocol, UITextFieldDelegate, KeyboardDismissable, ActivityViewProvider {
    
    var presenter: WeakWrapper<SignUpPresenterProtocol> = WeakWrapper()
    
    var avatarImageView = UIImageView()
    let inputUsername = UITextField()
    let inputFirstName = UITextField()
    let inputLastName = UITextField()
    let inputEmail = UITextField()
    let submitButton = Button.build(style: .solid)
    let imagePickerController = ImagePickerController()
    var activity: NVActivityIndicatorView?
    
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
        imagePickerController.delegate = self
        
        Background.build(in: container)
        
        activity = ActivityIndicator.build(in: container)
        
        let camera_img = UIImage(named: Contants.signupScreenCameraIcon)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(profileImageClicked))
        avatarImageView = UIImageView(frame: CGRect(x:0, y:0, width: 170, height: 170))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(singleTap)
        avatarImageView.contentMode =  UIView.ContentMode.scaleAspectFit
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.masksToBounds = false
        avatarImageView.layer.borderColor = UIColor.init(hexFromString: Contants.signupScreenTextColor).cgColor
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.clipsToBounds = true
        avatarImageView.image = camera_img
        container.addSubview(avatarImageView)
        
        inputUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.signupScreenForegroundColor)])
        inputUsername.borderStyle = UITextField.BorderStyle.none
        inputUsername.backgroundColor = nil
        inputUsername.textColor = UIColor.init(hexFromString: Contants.signupScreenTextColor)
        inputUsername.keyboardType = UIKeyboardType.default
        inputUsername.autocapitalizationType = UITextAutocapitalizationType.none
        inputUsername.autocorrectionType = UITextAutocorrectionType.no
        inputUsername.background = UIImage(named: Contants.globalLine)
        inputUsername.delegate = self
        container.addSubview(inputUsername)
        
        
        inputFirstName.attributedPlaceholder = NSAttributedString(string: "First name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.signupScreenForegroundColor)])
        inputFirstName.borderStyle = UITextField.BorderStyle.none
        inputFirstName.backgroundColor = nil
        inputFirstName.textColor = UIColor.init(hexFromString: Contants.signupScreenTextColor)
        inputFirstName.keyboardType = UIKeyboardType.alphabet
        inputFirstName.autocapitalizationType = UITextAutocapitalizationType.words
        inputFirstName.autocorrectionType = UITextAutocorrectionType.no
        inputFirstName.background = UIImage(named: Contants.globalLine)
        inputFirstName.delegate = self
        container.addSubview(inputFirstName)
        
        inputLastName.attributedPlaceholder = NSAttributedString(string: "Last name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.signupScreenForegroundColor)])
        inputLastName.borderStyle = UITextField.BorderStyle.none
        inputLastName.backgroundColor = nil
        inputLastName.textColor = UIColor.init(hexFromString: Contants.signupScreenTextColor)
        inputLastName.keyboardType = UIKeyboardType.alphabet
        inputLastName.autocapitalizationType = UITextAutocapitalizationType.words
        inputLastName.autocorrectionType = UITextAutocorrectionType.no
        inputLastName.background = UIImage(named: Contants.globalLine)
        inputLastName.delegate = self
        container.addSubview(inputLastName)
        
        inputEmail.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexFromString: Contants.signupScreenForegroundColor)])
        inputEmail.borderStyle = UITextField.BorderStyle.none
        inputEmail.backgroundColor = nil
        inputEmail.textColor = UIColor.init(hexFromString: Contants.signupScreenTextColor)
        inputEmail.autocapitalizationType = UITextAutocapitalizationType.none
        inputEmail.keyboardType = UIKeyboardType.emailAddress
        inputEmail.autocorrectionType = UITextAutocorrectionType.no
        inputEmail.background = UIImage(named: Contants.globalLine)
        inputEmail.delegate = self
        container.addSubview(inputEmail)
        
        submitButton.addTarget(self, action: #selector(submitMember), for: .touchUpInside)
        submitButton.setTitle("Submit", for: .normal)
        container.addSubview(submitButton)
        
        let clearButton = UIButton()
        clearButton.addTarget(self, action: #selector(profileImageCleared), for: .touchUpInside)
        clearButton.titleLabel?.font = .systemFont(ofSize: 15)
        clearButton.titleLabel?.textColor = UIColor.init(hexFromString: Contants.signupScreenForegroundColor)
        clearButton.setTitle("Clear", for: UIControl.State.normal)
        container.addSubview(clearButton)
        
        setAvatarImageViewConstraints(with: 190)

        inputUsername.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(avatarImageView.safeAreaLayoutGuide.snp.bottom).offset(70)
        }
        inputFirstName.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(inputUsername.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        inputLastName.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(inputFirstName.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        inputEmail.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(inputLastName.safeAreaLayoutGuide.snp.bottom).offset(40)
        }
        clearButton.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(40)
            make.width.equalTo(80)
            make.centerX.equalTo(avatarImageView.snp.centerX)
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(40)
        }
        submitButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    @objc func submitMember(sender: UIButton!) {
        presenter.wrapped?.submit()
    }
    
    // Profile picture capture
    @objc func profileImageClicked() {
        imagePickerController.showPicker(from: self)
    }
    
    // Profile picture clear
    @objc func profileImageCleared() {
        avatarImageView.image = UIImage(named: "camera-icon")
        presenter.wrapped?.clearProfilePicture()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func cleanUp() {
        avatarImageView.image = UIImage(named: "camera-icon")
        inputUsername.text = ""
        inputFirstName.text = ""
        inputLastName.text = ""
        inputEmail.text = ""
    }
    
    func setAvatarImageViewConstraints(with offset: Float) {
        avatarImageView.snp.remakeConstraints { (make) -> Void in
            make.height.equalTo(170)
            make.width.equalTo(170)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(offset)
        }
    }
        
    // MARK: SignUpViewProtocol
    
    func setSubmitButtonEnabled(_ enabled: Bool) {
        submitButton.isEnabled = enabled
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        switch textField {
        case inputUsername:
            presenter.wrapped?.setUsername(inputUsername.text ?? "")
        case inputFirstName:
            presenter.wrapped?.setFirstName(inputFirstName.text ?? "")
        case inputLastName:
            presenter.wrapped?.setLastName(inputLastName.text ?? "")
        case inputEmail:
            presenter.wrapped?.setEmailAddress(inputEmail.text ?? "")
        default:
            break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if device(is: .iPhone5) {
            UIView.animate(withDuration: 0.3) {
                self.setAvatarImageViewConstraints(with: 190)
                self.avatarImageView.superview?.layoutIfNeeded()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if device(is: .iPhone5) {
            UIView.animate(withDuration: 0.3) {
                self.setAvatarImageViewConstraints(with: 90)
                self.avatarImageView.superview?.layoutIfNeeded()
            }
        }
    }
        
    // MARK: ImagePickerControllerDelegate
    
    func imagePickerController(_ controller: ImagePickerController, imageSelected image: UIImage) {
        let scaledImage = image.scaleImage(toSize: CGSize(width: 512, height: 512))
        avatarImageView.image = scaledImage
        presenter.wrapped?.setProfilePicture(scaledImage ?? image)
    }
}
