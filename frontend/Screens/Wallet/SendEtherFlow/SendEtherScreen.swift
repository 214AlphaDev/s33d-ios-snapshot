//
//  SendEtherFlow.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/23/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import UIKit
import WalletKit
import FlowKit
import NVActivityIndicatorView

class SendEtherScreen: UIViewController, SendEtherViewProtocol, ActivityViewProvider, KeyboardDismissable {
    
    var presenter: WeakWrapper<SendEtherPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    
    let addressTextField = UITextField()
    let ethAmountEnterView = CurrencyAmountEnterView(currencyName: "ETH")
    let usdAmountEnterView = CurrencyAmountEnterView(currencyName: "USD")
    let highGasButton = Button.build(style: .transparent)
    let mediumGasButton = Button.build(style: .transparent)
    let lowGasButton = Button.build(style: .transparent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
        gasButtonTapped(sender: highGasButton)
        keyboardDismissAction = setupKeyboardDismissRecognizer()
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        let navigationBar = createNavigationBar(in: view)
        
        let scrollView = UIScrollView()
        container.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
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
        let addressCaptionLabel = UILabel()
        addressCaptionLabel.font = Fonts.font(of: 20.0, weight: .medium)
        addressCaptionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.75)
        addressCaptionLabel.textAlignment = .left
        addressCaptionLabel.text = "To: "
        
        container.addSubview(addressCaptionLabel)
        
        addressTextField.attributedPlaceholder = NSAttributedString(string: "Enter ETH Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)])
        addressTextField.font = Fonts.font(of: 18.0, weight: .medium)
        addressTextField.borderStyle = UITextField.BorderStyle.none
        addressTextField.backgroundColor = nil
        addressTextField.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        addressTextField.keyboardType = UIKeyboardType.default
        addressTextField.addTarget(self, action: #selector(addressChanged), for: .editingChanged)
        
        container.addSubview(addressTextField)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        container.addSubview(separatorView)
        
        let ethereumView = UIView()
        container.addSubview(ethereumView)
        
        let ethereumIconImageView = UIImageView()
        ethereumIconImageView.image = UIImage(named: "ethereum")
        ethereumView.addSubview(ethereumIconImageView)
        
        let ethereumLabel = UILabel()
        ethereumLabel.font = Fonts.font(of: 20.0, weight: .medium)
        ethereumLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        ethereumLabel.textAlignment = .left
        ethereumLabel.text = "Ethereum (ETH)"
        ethereumView.addSubview(ethereumLabel)
        
        ethAmountEnterView.amountTextField.addTarget(self, action: #selector(ethAmountChanged), for: .editingChanged)
        usdAmountEnterView.amountTextField.addTarget(self, action: #selector(usdAmountChanged), for: .editingChanged)
        
        container.addSubview(ethAmountEnterView.view)
        container.addSubview(usdAmountEnterView.view)
        
        let gasCaptionLabel = UILabel()
        gasCaptionLabel.font = Fonts.font(of: 20.0, weight: .medium)
        gasCaptionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.75)
        gasCaptionLabel.textAlignment = .left
        gasCaptionLabel.text = "Gas"
        container.addSubview(gasCaptionLabel)
        
        highGasButton.setTitle("High", for: .normal)
        mediumGasButton.setTitle("Med", for: .normal)
        lowGasButton.setTitle("Low", for: .normal)
        [highGasButton, mediumGasButton, lowGasButton].forEach { button in
            button.addTarget(self, action: #selector(gasButtonTapped), for: .touchUpInside)
        }
        
        let gasButtonsStackView = UIStackView(arrangedSubviews: [highGasButton, mediumGasButton, lowGasButton])
        gasButtonsStackView.axis = .horizontal
        gasButtonsStackView.distribution = .equalSpacing
        container.addSubview(gasButtonsStackView)
        
        let sendButton = Button.build(style: .solid)
        sendButton.setTitle("Confirm & Send", for: .normal)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        container.addSubview(sendButton)
        
        addressCaptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.left.equalToSuperview().offset(26)
        }
        
        addressTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.centerY.equalTo(addressCaptionLabel)
            make.right.equalToSuperview().offset(-26)
            make.left.equalTo(addressCaptionLabel.snp.right).offset(10)
        }
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(addressTextField.snp.bottom).offset(30)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        ethereumView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom).offset(40)
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
        }
        
        ethereumIconImageView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        ethereumLabel.snp.makeConstraints { make in
            make.left.equalTo(ethereumIconImageView.snp.right).offset(20)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        ethAmountEnterView.view.snp.makeConstraints { make in
            make.top.equalTo(ethereumView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(70)
            make.right.equalToSuperview().offset(-26)
        }
        
        usdAmountEnterView.view.snp.makeConstraints { make in
            make.top.equalTo(ethAmountEnterView.view.snp.bottom).offset(16)
            make.left.equalTo(ethAmountEnterView.view)
            make.right.equalTo(ethAmountEnterView.view)
        }
        
        gasCaptionLabel.snp.makeConstraints { make in
            make.left.equalTo(26)
            make.top.equalTo(usdAmountEnterView.view.snp.bottom).offset(60)
            make.height.equalTo(44)
        }
        
        [highGasButton, mediumGasButton, lowGasButton].forEach { button in
            button.snp.remakeConstraints { make in
                make.height.equalTo(44)
                make.width.equalTo(62)
            }
        }
        
        gasButtonsStackView.snp.makeConstraints { make in
            make.left.equalTo(gasCaptionLabel.snp.right).offset(20)
            make.right.equalToSuperview().offset(-26)
            make.centerY.equalTo(gasCaptionLabel)
        }
        
        sendButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalTo(gasCaptionLabel.snp.bottom).offset(60)
            make.bottom.equalToSuperview().offset(-26)
        }
        
    }
    
    func createNavigationBar(in container: UIView) -> UINavigationBar {
        let navigationBar = UINavigationBar()
        DefaultNavigationController.configureNavigationBar(navigationBar)
        container.addSubview(navigationBar)
        navigationBar.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        
        navigationBar.snp.makeConstraints { make in
            make.height.equalTo(64)
            make.top.equalTo(container.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let navigationItem = UINavigationItem(title: "Send")
        navigationBar.items = [navigationItem]
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = BarButtonItem.configured(item: closeItem)
        
        return navigationBar
    }
    
    func setUSDFieldEnabled(_ enabled: Bool) {
        usdAmountEnterView.amountTextField.isEnabled = enabled
        usdAmountEnterView.view.alpha = enabled ? 1.0 : 0.5
    }
    
    func displayETHAmountString(_ amountString: String) {
        ethAmountEnterView.amountTextField.text = amountString
    }
    
    func displayUSDAmountString(_ amountString: String) {
        usdAmountEnterView.amountTextField.text = amountString
    }
    
    @objc func ethAmountChanged(sender: Any?) {
        presenter.wrapped?.setETHAmountString(ethAmountEnterView.amountTextField.text ?? "")
    }
    
    @objc func usdAmountChanged(sender: Any?) {
        presenter.wrapped?.setUSDAmountString(usdAmountEnterView.amountTextField.text ?? "")
    }
    
    @objc func addressChanged(sender: Any?) {
        presenter.wrapped?.setAddress(addressTextField.text ?? "")
    }
    
    @objc func gasButtonTapped(sender: UIButton) {
        if sender === highGasButton {
            highGasButton.alpha = 1.0
            mediumGasButton.alpha = 0.5
            lowGasButton.alpha = 0.5
            presenter.wrapped?.setTransactionSpeed(.high)
        }
        if sender === mediumGasButton {
            highGasButton.alpha = 0.5
            mediumGasButton.alpha = 1
            lowGasButton.alpha = 0.5
            presenter.wrapped?.setTransactionSpeed(.medium)
        }
        if sender === lowGasButton {
            highGasButton.alpha = 0.5
            mediumGasButton.alpha = 0.5
            lowGasButton.alpha = 1
            presenter.wrapped?.setTransactionSpeed(.low)
        }
    }
    
    @objc func sendTapped(sender: Any?) {
        presenter.wrapped?.send()
    }
    
    @objc func closeTapped(sender: Any?) {
        presenter.wrapped?.close()
    }
    
}


struct CurrencyAmountEnterView {
    
    let view: UIView
    let amountTextField = UITextField()
    
    init(currencyName: String) {
        view = UIView()
        
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Enter \(currencyName) amount", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)])
        amountTextField.font = Fonts.font(of: 18.0, weight: .medium)
        amountTextField.borderStyle = UITextField.BorderStyle.none
        amountTextField.backgroundColor = nil
        amountTextField.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        amountTextField.keyboardType = UIKeyboardType.decimalPad
        view.addSubview(amountTextField)
        
        let nameLabel = UILabel()
        nameLabel.font = Fonts.font(of: 20.0, weight: .medium)
        nameLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        nameLabel.text = currencyName
        nameLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.addSubview(nameLabel)
        
        let underlineView = UIView()
        underlineView.backgroundColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        view.addSubview(underlineView)
        
        amountTextField.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(amountTextField.snp.right).offset(23)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        underlineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(amountTextField)
            make.right.equalTo(amountTextField)
        }
        
    }
    
    func setAmount(_ amountString: String) {
        amountTextField.text = amountString
    }
    
}
