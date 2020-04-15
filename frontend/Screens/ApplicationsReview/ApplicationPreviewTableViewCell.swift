//
//  ApplicationPreviewTableViewCell.swift
//  s33d
//
//  Created by Andrii Selivanov on 4/1/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit
import CommunityKit

class ApplicationPreviewTableViewCell: UITableViewCell {
    
    let memberNameLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.font(of: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.buildUI(in: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func buildUI(in container: UIView) {
        container.addSubview(memberNameLabel)
        container.backgroundColor = .clear
        memberNameLabel.snp.makeConstraints { make -> Void in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalTo(container).offset(32)
        }
    }
    
    public func customize(with application: MemberApplicationViewData) {
        self.memberNameLabel.text = application.member.properName.firstName + " " + application.member.properName.lastName
    }
    
}
