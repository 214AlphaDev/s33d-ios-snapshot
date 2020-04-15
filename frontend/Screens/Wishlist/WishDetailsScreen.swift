//
//  WishDetailsScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 5/6/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import WishKit
import FlowKit

class WishDetailsScreen: UIViewController, ActivityViewProvider, WishDetailsViewProtocol {
    
    var presenter: WeakWrapper<WishDetailsPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    var wish: Wish!
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let storyLabel = UILabel()
    let categoryImageView = UIImageView()
    let voteButton = Button.build(style: .icon(UIImage(named: "like_empty")!))
    let withdrawVoteButton = Button.build(style: .icon(UIImage(named: "like_filled")!))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        container.addSubview(categoryImageView)
        
        nameLabel.font = Fonts.font(of: 22.0, weight: .bold)
        nameLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        nameLabel.numberOfLines = 0
        
        container.addSubview(nameLabel)
        
        descriptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        descriptionLabel.font = Fonts.font(of: 18.0, weight: .regular)
        descriptionLabel.numberOfLines = 0
        container.addSubview(descriptionLabel)
        
        let storyCaptionLabel = UILabel()
        storyCaptionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)
        storyCaptionLabel.font = Fonts.font(of: 16, weight: .medium)
        storyCaptionLabel.text = "Story"
        container.addSubview(storyCaptionLabel)
        
        let descriptionCaptionLabel = UILabel()
        descriptionCaptionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)
        descriptionCaptionLabel.font = Fonts.font(of: 16, weight: .medium)
        descriptionCaptionLabel.text = "Description"
        container.addSubview(descriptionCaptionLabel)
        
        storyLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        storyLabel.font = Fonts.font(of: 18.0, weight: .regular)
        storyLabel.numberOfLines = 0
        container.addSubview(storyLabel)
        
        voteButton.addTarget(self, action: #selector(voteForItem), for: .touchUpInside)
        container.addSubview(voteButton)
        
        withdrawVoteButton.addTarget(self, action: #selector(withdrawVoteFromItem), for: .touchUpInside)
        container.addSubview(withdrawVoteButton)
        
        categoryImageView.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.size.equalTo(100)
            make.top.equalTo(container.snp.top)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(voteButton.snp.left).offset(-26)
            make.centerY.equalTo(voteButton.snp.centerY)
            make.top.equalTo(categoryImageView.snp.bottom).offset(20)
        }
        
        voteButton.snp.makeConstraints { make in
            make.height.equalTo(voteButton.snp.width)
            make.right.equalTo(container.snp.right).offset(-26)
        }
        
        withdrawVoteButton.snp.makeConstraints { make in
            make.edges.equalTo(voteButton.snp.edges)
        }
        
        descriptionCaptionLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionLabel)
            make.right.equalTo(descriptionLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(descriptionCaptionLabel.snp.bottom).offset(5)
        }
        
        storyCaptionLabel.snp.makeConstraints { make in
            make.left.equalTo(storyLabel)
            make.right.equalTo(storyLabel)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
        }
        
        storyLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(storyCaptionLabel.snp.bottom).offset(5)
            make.bottom.equalTo(container.snp.bottom).offset(-8)
        }
        
    }
    
    func displayWish(_ wish: Wish) {
        nameLabel.text = wish.name
        descriptionLabel.text = wish.description
        storyLabel.text = wish.story ?? ""
        voteButton.isHidden = wish.isVoted
        withdrawVoteButton.isHidden = !wish.isVoted
        categoryImageView.image = CategoryPicker.Category(wishCategory: wish.category).icon
    }
    
    @objc func voteForItem(sender: Any?) {
        presenter.wrapped?.vote()
    }

    @objc func withdrawVoteFromItem(sender: Any?) {
        presenter.wrapped?.withdrawVote()
    }
    
}

