//
//  CreateMnemonicScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/21/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import WalletKit
import FlowKit
import NVActivityIndicatorView

class CreateMnemonicScreen: UIViewController, CreateMnemonicViewProtocol, ActivityViewProvider {
    
    var presenter: WeakWrapper<CreateMnemonicPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    let mnemonicLabels: [UILabel] = {
        var labels = [UILabel]()
        for index in 0..<12 {
            labels.append(UILabel())
        }
        
        return labels
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Seed Phrase"
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
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
        let descriptionLabel = UILabel()
        descriptionLabel.font = Fonts.font(of: 18.0, weight: .regular)
        descriptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "If you ever lose your device you can restore your wallet using this back-up seed phrase.\n\nMake sure you write it down and keep it extra safe."
        
        container.addSubview(descriptionLabel)
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(named: "wallet_seed_icon")
        container.addSubview(iconImageView)
        
        let mnemonicLabelsView = buildMnemonicLabelsView()
        container.addSubview(mnemonicLabelsView)
        
        let confirmButton = Button.build(style: .solid)
        confirmButton.setTitle("Confirm Seed Phrase", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        container.addSubview(confirmButton)
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(container).offset(26)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(26)
        }
        
        mnemonicLabelsView.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(40)
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container.snp.right).offset(-26)
            make.top.equalTo(mnemonicLabelsView.snp.bottom).offset(60)
            make.bottom.equalTo(container).offset(-60)
        }
    }
    
    func buildMnemonicLabelsView() -> UIView {
        mnemonicLabels.forEach { label in
            label.font = Fonts.font(of: 18.0, weight: .bold)
            label.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
            label.numberOfLines = 1
            label.minimumScaleFactor = 0.5
            label.adjustsFontSizeToFitWidth = true
        }
        
        return GridView.build(from: mnemonicLabels, width: 3, height: 4)
    }
    
    func setMnemonicWords(_ words: [String]) {
        for index in 0..<min(words.count, mnemonicLabels.count) {
            mnemonicLabels[index].text = "\(index + 1).  \(words[index])"
        }
    }
    
    @objc func confirmButtonTapped(sender: Any?) {
        presenter.wrapped?.goToMnemonicConfirmation()
    }
    
}

