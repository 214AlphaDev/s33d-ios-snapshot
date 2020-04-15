//
//  WalletOverviewScreen.swift
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

class WalletOverviewScreen: UIViewController, WalletOverviewViewProtocol, ActivityViewProvider {
   
   
    
    
    
    
    var presenter: WeakWrapper<WalletOverviewPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    let usdBalanceLabel = UILabel()
    let ethBalanceView = CurrencyBalanceView(currencyName: "Ethereum", currencySymbol: "ETH", iconImage: UIImage(named: "ethereum")!)
    let balanceView1 = CurrencyBalanceView(currencyName:  Contants.walletBalanceView1CurrencyName, currencySymbol:  Contants.walletBalanceView1CurrencySymbol, iconImage: UIImage(named: Contants.walletBalanceView1CurrencyIcon)!)
    let balanceView2 = CurrencyBalanceView(currencyName: Contants.walletBalanceView2CurrencyName, currencySymbol: Contants.walletBalanceView2CurrencySymbol, iconImage: UIImage(named: Contants.walletBalanceView2CurrencyIcon)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        let navigationBar = createNavigationBar(in: view)
        
        let balanceCaptionLabel = UILabel()
        balanceCaptionLabel.font = Fonts.font(of: 20.0, weight: .bold)
        balanceCaptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        balanceCaptionLabel.textAlignment = .left
        balanceCaptionLabel.text = "Balance"
        
        container.addSubview(balanceCaptionLabel)
        
        usdBalanceLabel.font = Fonts.font(of: 18.0, weight: .regular)
        usdBalanceLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        usdBalanceLabel.numberOfLines = 1
        usdBalanceLabel.textAlignment = .right
        
        container.addSubview(usdBalanceLabel)
        
        let tokensCaptionLabel = UILabel()
        tokensCaptionLabel.font = Fonts.font(of: 20.0, weight: .bold)
        tokensCaptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        tokensCaptionLabel.textAlignment = .left
        tokensCaptionLabel.text = "Tokens"
        
        container.addSubview(tokensCaptionLabel)
        
        container.addSubview(ethBalanceView.view)
        container.addSubview(balanceView1.view)
        container.addSubview(balanceView2.view)
        balanceView1.view.alpha = 0.5
        balanceView1.setUSDAmount("$0")
        balanceView1.setCurrencyAmount("0")
        
        balanceView2.view.alpha = 0.5
        balanceView2.setUSDAmount("$0")
        balanceView2.setCurrencyAmount("0")
        
        let sendEtherButton = Button.build(style: .solid)
        sendEtherButton.setTitle("Send", for: .normal)
        sendEtherButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        container.addSubview(sendEtherButton)
        
        let receiveEtherButton = Button.build(style: .transparent)
        receiveEtherButton.setTitle("Receive", for: .normal)
        receiveEtherButton.addTarget(self, action: #selector(receiveButtonTapped), for: .touchUpInside)
        container.addSubview(receiveEtherButton)
        
        balanceCaptionLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.top.equalTo(navigationBar.snp.bottom).offset(40)
        }
        
        usdBalanceLabel.snp.makeConstraints { make in
            make.right.equalTo(container.snp.right).offset(-26)
            make.centerY.equalTo(balanceCaptionLabel.snp.centerY)
        }
        
        tokensCaptionLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.top.equalTo(balanceCaptionLabel.snp.bottom).offset(40)
        }
        
        ethBalanceView.view.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(tokensCaptionLabel.snp.bottom).offset(26)
        }
        
        balanceView1.view.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(ethBalanceView.view.snp.bottom).offset(20)
        }
        
        balanceView2.view.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(balanceView1.view.snp.bottom).offset(20)
        }
        
        sendEtherButton.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.top.equalTo(balanceView2.view.snp.bottom).offset(40)
        }
        
        receiveEtherButton.snp.makeConstraints { make in
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(sendEtherButton.snp.top)
            make.left.equalTo(sendEtherButton.snp.right).offset(10)
            make.width.equalTo(sendEtherButton.snp.width)
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
        
        let navigationItem = UINavigationItem(title: "Wallet")
        navigationBar.items = [navigationItem]
        
        let refreshItem = UIBarButtonItem(image: UIImage(named: "refresh_icon"), style: .plain, target: self, action: #selector(refreshTapped))
        navigationItem.rightBarButtonItem = BarButtonItem.configured(item: refreshItem)
        
        return navigationBar
    }
    
    func displayETHBalance(_ balanceString: String) {
        ethBalanceView.setCurrencyAmount(balanceString)
    }
    
    func displayUSDBalance(_ balanceString: String) {
        usdBalanceLabel.text = balanceString
        ethBalanceView.setUSDAmount(balanceString)
    }
    
    @objc func refreshTapped(sender: Any?) {
        presenter.wrapped?.refreshBalance()
    }
    
    @objc func sendButtonTapped(sender: Any?) {
        presenter.wrapped?.goToSendEther()
    }
    
    @objc func receiveButtonTapped(sender: Any?) {
        presenter.wrapped?.goToReceiveEther()
    }
    
}

struct CurrencyBalanceView {
    
    let view: UIView
    let currencyAmountLabel = UILabel()
    let usdAmountLabel = UILabel()
    
    init(currencyName: String, currencySymbol: String, iconImage: UIImage) {
        view = UIView()
        
        let nameLabel = UILabel()
        nameLabel.font = Fonts.font(of: 18.0, weight: .medium)
        nameLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        nameLabel.text = currencyName
        view.addSubview(nameLabel)
        
        let symbolLabel = UILabel()
        symbolLabel.font = Fonts.font(of: 12.0, weight: .light)
        symbolLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        symbolLabel.text = currencySymbol
        symbolLabel.alpha = 0.75
        view.addSubview(symbolLabel)
        
        let iconImageView = UIImageView()
        iconImageView.image = iconImage
        view.addSubview(iconImageView)
        
        currencyAmountLabel.font = Fonts.font(of: 18.0, weight: .medium)
        currencyAmountLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        view.addSubview(currencyAmountLabel)
        
        usdAmountLabel.font = Fonts.font(of: 12.0, weight: .light)
        usdAmountLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        usdAmountLabel.alpha = 0.75
        view.addSubview(usdAmountLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.top.equalToSuperview()
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(20)
            make.top.equalTo(nameLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        currencyAmountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        usdAmountLabel.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(currencyAmountLabel.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
    
    func setCurrencyAmount(_ amountString: String) {
        self.currencyAmountLabel.text = amountString
    }
    
    func setUSDAmount(_ amountString: String) {
        self.usdAmountLabel.text = amountString
    }
    
}
