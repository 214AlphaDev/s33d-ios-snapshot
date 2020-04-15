//
//  EnterMnemonicScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/21/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import WalletKit
import FlowKit
import NVActivityIndicatorView

class EnterMnemonicScreen: UIViewController, EnterMnemonicViewProtocol, ActivityViewProvider, KeyboardDismissable {
    
    var presenter: WeakWrapper<EnterMnemonicPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    let mnemonicTextFields: [UITextField] = {
        var textFields = [UITextField]()
        for index in 0..<12 {
            textFields.append(UITextField())
        }
        
        return textFields
    }()
    let confirmButton = Button.build(style: .solid)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
        updateSubmitEnabled()
        keyboardDismissAction = setupKeyboardDismissRecognizer()
    }
    
    func setMnemonicEnterObjective(_ objective: MnemonicEnterObjective) {
        switch objective {
        case .confirm:
            navigationItem.title = "Confirm Seed Phrase"
            confirmButton.setTitle("Confirm Seed & Finish", for: .normal)
        case .restore:
            navigationItem.title = "Enter Seed Phrase"
            confirmButton.setTitle("Restore Wallet", for: .normal)
        }
        
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        container.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(container.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom)
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        createScrollViewContent(in: contentView)
    }
    
    func createScrollViewContent(in container: UIView) {
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "wallet_seed_icon")
        container.addSubview(iconImageView)
        
        let mnemonicTextFieldsView = buildMnemonicTextFieldsView()
        container.addSubview(mnemonicTextFieldsView)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        container.addSubview(confirmButton)
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(40)
        }
        
        mnemonicTextFieldsView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(40)
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(mnemonicTextFieldsView.snp.bottom).offset(60)
            make.bottom.equalTo(container).offset(-60)
        }
    }
    
    func buildMnemonicTextFieldsView() -> UIView {
        mnemonicTextFields.forEach { textField in
            textField.borderStyle = UITextField.BorderStyle.none
            textField.backgroundColor = .clear
            textField.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
            textField.keyboardType = UIKeyboardType.default
            textField.font = Fonts.font(of: 18, weight: .bold)
            textField.delegate = self
            textField.tag = (mnemonicTextFields.firstIndex(of: textField) ?? 0) + 1
            textField.text = textFieldPrefix(with: textField.tag)
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .none
            textField.returnKeyType = .next
            textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        
        mnemonicTextFields.last?.returnKeyType = .done
        
        return GridView.build(from: mnemonicTextFields, width: 3, height: 4, configuration: .init(verticalSpacing: 40, horizontalSpacing: 8))
    }
    
    @objc func confirmButtonTapped(sender: Any?) {
        presenter.wrapped?.submit()
    }
    
    func textFieldPrefix(with number: Int) -> String {
        return "\(number).  "
    }
    
    func textFieldRealText(at index: Int) -> String {
        let textField = mnemonicTextFields[index]
        var text = textField.text ?? ""
        // Removing prefix
        text.removeFirst(textFieldPrefix(with: textField.tag).count)
        
        return text
    }
    
    func updateSubmitEnabled() {
        guard let presenterInstance = presenter.wrapped else {
            return
        }
        
        for index in 0..<mnemonicTextFields.count {
            if case .invalid(_) =  presenterInstance.validateMnemonicWord(textFieldRealText(at: index), partialAllowed: false) {
                confirmButton.isEnabled = false
                return
            }
        }
        
        confirmButton.isEnabled = true
    }
    
    func cleanUp() {
        mnemonicTextFields.forEach { textField in
            textField.text = textFieldPrefix(with: textField.tag)
        }
        updateSubmitEnabled()
    }
    
}

extension EnterMnemonicScreen: UITextFieldDelegate {
    
    @objc func textFieldDidChange(textField: UITextField) {
        guard textField.tag > 0 else {
            return
        }
        
        let index = textField.tag - 1
        presenter.wrapped?.setMnemonicWord(textFieldRealText(at: index), at: index)
        updateSubmitEnabled()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard textField.tag > 0 else {
            return true
        }
        
        let index = textField.tag - 1
        let nextIndex = index + 1
        if nextIndex < mnemonicTextFields.count {
            mnemonicTextFields[nextIndex].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.tag > 0 else {
            return true
        }
        
        let currentString = textField.text ?? ""
        let resultString = NSString(string: currentString)
            .replacingCharacters(in: range, with: string)
        
        return resultString.hasPrefix(textFieldPrefix(with: textField.tag))
    }
    
}
