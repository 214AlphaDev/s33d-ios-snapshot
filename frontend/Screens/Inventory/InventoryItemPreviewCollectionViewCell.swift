//
//  InventoryItemPreviewCollectionViewCell.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/26/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import InventoryKit

class InventoryItemPreviewCollectionViewCell: UICollectionViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(of: 16, weight: .regular)
        label.textAlignment = .left
        label.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 11
        
        return imageView
    }()
    
    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        shadowView.layer.cornerRadius = 11
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 2
        shadowView.layer.masksToBounds = false
        shadowView.layer.shouldRasterize = true
        shadowView.layer.rasterizationScale =  UIScreen.main.scale
        
        return shadowView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let container = UIView()
        contentView.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.buildUI(in: container)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("InventoryItemPreviewCollectionViewCell is not designed to be init with coder")
    }
    
    private func buildUI(in container: UIView) {
        container.addSubview(nameLabel)
        container.addSubview(shadowView)
        container.addSubview(photoImageView)
        container.backgroundColor = .clear
        
        photoImageView.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.top.equalTo(photoImageView.snp.bottom).offset(10)
        }
        
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(photoImageView)
        }
        
    }
    
    public func customize(with item: InventoryItem) {
        nameLabel.text = item.name
        photoImageView.image = item.photo?.picture
        
        if (photoImageView.image == nil) {
            photoImageView.backgroundColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        }
    }
    
}

