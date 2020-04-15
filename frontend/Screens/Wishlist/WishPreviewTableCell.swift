//
//  WishPreviewTableViewCell.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 5/6/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit
import WishKit

class WishPreviewTableViewCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(of: 18, weight: .medium)
        label.textAlignment = .left
        label.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let descriptionPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(of: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()
    
    let categoryImageView = UIImageView()
    
    let votedIconImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        let container = UIView()
        contentView.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        self.buildUI(in: container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildUI(in container: UIView) {
        container.addSubview(nameLabel)
        container.addSubview(descriptionPreviewLabel)
        container.addSubview(votedIconImageView)
        container.addSubview(categoryImageView)
        container.backgroundColor = .clear
        
        categoryImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.size.equalTo(32)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(categoryImageView.snp.right).offset(20)
            make.top.equalToSuperview()
        }
        
        votedIconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.left.equalTo(nameLabel.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(nameLabel)
        }
        
        descriptionPreviewLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(3)
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    public func customize(with wish: Wish) {
        
        categoryImageView.image = CategoryPicker.Category(wishCategory: wish.category).icon
        nameLabel.text = wish.name
        descriptionPreviewLabel.text = wish.description
        
        votedIconImageView.image = wish.isVoted ? UIImage(named: "like_filled") : UIImage(named: "like_empty")
    }
    
}

