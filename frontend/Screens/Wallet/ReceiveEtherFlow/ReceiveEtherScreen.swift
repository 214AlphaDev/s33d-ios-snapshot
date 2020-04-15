//
//  ReceiveEtherScreen.swift
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

class ReceiveEtherScreen: UIViewController, ReceiveEtherViewProtocol, ActivityViewProvider {
    
    var presenter: WeakWrapper<ReceiveEtherPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    
    let qrCodeImageView = UIImageView()
    let addressLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
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
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(white: 1.0, alpha: 0.25)
        container.addSubview(separatorView)
        
        container.addSubview(qrCodeImageView)
        
        let addressCaptionLabel = UILabel()
        addressCaptionLabel.font = Fonts.font(of: 20.0, weight: .bold)
        addressCaptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        addressCaptionLabel.textAlignment = .center
        addressCaptionLabel.text = "Address"
        
        container.addSubview(addressCaptionLabel)
        
        addressLabel.font = Fonts.font(of: 18.0, weight: .medium)
        addressLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        addressLabel.textAlignment = .center
        addressLabel.numberOfLines = 0
        
        container.addSubview(addressLabel)
        
        let copyAddressButton = Button.build(style: .solid)
        copyAddressButton.setTitle("Copy Address to Clipboard", for: .normal)
        copyAddressButton.addTarget(self, action: #selector(copyAddressTapped), for: .touchUpInside)
        container.addSubview(copyAddressButton)
        
        ethereumView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
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
        
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.top.equalTo(ethereumView.snp.bottom).offset(30)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        qrCodeImageView.snp.makeConstraints { make in
            make.height.equalTo(175)
            make.width.equalTo(175)
            make.centerX.equalToSuperview()
            make.top.equalTo(separatorView.snp.bottom).offset(80)
        }
        
        addressCaptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(qrCodeImageView.snp.bottom).offset(20)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalTo(addressCaptionLabel.snp.bottom).offset(20)
        }
        
        copyAddressButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(26)
            make.right.equalToSuperview().offset(-26)
            make.top.equalTo(addressLabel.snp.bottom).offset(20)
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
        
        let navigationItem = UINavigationItem(title: "Receive")
        navigationBar.items = [navigationItem]
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "close_icon"), style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = BarButtonItem.configured(item: closeItem)
        
        return navigationBar
    }
    
    func displayAddress(_ address: String) {
        qrCodeImageView.image = generateQRCode(from: address)
        addressLabel.text = address
    }
    
    @objc func copyAddressTapped(sender: Any?) {
        presenter.wrapped?.copyAddressToClipboard()
    }
    
    @objc func closeTapped(sender: Any?) {
        presenter.wrapped?.close()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
}

