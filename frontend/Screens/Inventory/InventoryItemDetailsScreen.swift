//
//  InventoryItemDetailsScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/26/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import InventoryKit
import FlowKit
import PopMenu
import QuickLook

extension InventoryItemDetailsScreen: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}

class InventoryItemDetailsScreen: UIViewController, ActivityViewProvider, InventoryItemDetailsViewProtocol {
    
    lazy var previewItem = NSURL()
    
    var presenter: WeakWrapper<InventoryItemDetailsPresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    var inventoryItem: InventoryItem!
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let storyLabel = UILabel()
    let storyCaptionLabel = UILabel()
    let voteButton = Button.build(style: .icon(UIImage(named: "like_empty")!))
    let withdrawVoteButton = Button.build(style: .icon(UIImage(named: "like_filled")!))
    let photoImageView = UIImageView()
    let photoPlaceholderImageView = UIImageView()
    let categoryImageView = UIImageView()
    var editAllowed: Bool = false
    var deleteAllowed: Bool = false
    
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
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFit
        photoImageView.layer.borderWidth = 0.5
        photoImageView.layer.cornerRadius = 5
        photoImageView.layer.borderColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor).cgColor
        container.addSubview(photoImageView)
        
        photoPlaceholderImageView.contentMode = .center
        photoPlaceholderImageView.image = UIImage(named: "photo")
        container.addSubview(photoPlaceholderImageView)
        
        container.addSubview(categoryImageView)
        
        nameLabel.font = Fonts.font(of: 22.0, weight: .bold)
        nameLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        nameLabel.numberOfLines = 0
        container.addSubview(nameLabel)
        
        descriptionLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        descriptionLabel.font = Fonts.font(of: 18.0, weight: .regular)
        descriptionLabel.numberOfLines = 0
        container.addSubview(descriptionLabel)
        
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
        
        photoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(container.snp.top).offset(20)
            make.height.equalTo(160)
            make.width.equalTo(160)
        }
        
        photoPlaceholderImageView.snp.makeConstraints { make in
            make.edges.equalTo(photoImageView)
        }
        
        categoryImageView.snp.makeConstraints { make in
            make.centerX.equalTo(container)
            make.size.equalTo(56)
            make.top.equalTo(photoImageView.snp.bottom).offset(20)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(voteButton.snp.left).offset(-26)
            make.centerY.equalTo(voteButton.snp.centerY)
            make.top.equalTo(categoryImageView.snp.bottom).offset(26)
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
    
    func updateNavigationItem() {
        if !editAllowed && !deleteAllowed {
            // No menu needed
            navigationItem.rightBarButtonItem = nil
            navigationItem.rightBarButtonItems = nil
            return
        }
        
        let menuItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .plain, target: self, action: #selector(menuTapped))
        menuItem.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        
        navigationItem.rightBarButtonItem = BarButtonItem.configured(item: menuItem)
    }
    
    func displayInventoryItem(_ item: InventoryItem) {
        // Make the inventory item accessible to other functions such as the qrCode one
        inventoryItem = item
        nameLabel.text = item.name
        descriptionLabel.text = item.description
        storyLabel.text = item.story ?? ""
        // Hide caption label if there is no story
        storyCaptionLabel.isHidden = item.story == nil
        voteButton.isHidden = item.isVoted
        withdrawVoteButton.isHidden = !item.isVoted
        photoImageView.image = item.photo?.picture
        // Hide placeholder if image is set
        photoPlaceholderImageView.isHidden = photoImageView.image != nil
        categoryImageView.image = CategoryPicker.Category(inventoryCategory: item.category).icon
    }
    
    func setDeleteAllowed(_ allowed: Bool) {
        deleteAllowed = allowed
        updateNavigationItem()
    }
    
    func setEditAllowed(_ allowed: Bool) {
        editAllowed = allowed
        updateNavigationItem()
    }
    
    func showDeleteConfirmationAlert() {
        presentAlert(controller: self, title: "Confirmation", message: "Are you sure you want to delete the item?") { controller in
            controller.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.presenter.wrapped?.delete()
            }))
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        }
    }
    
    struct qrCode : Codable {
        let name: String
        let description: String
        let story: String
        let category: String
    }
    
    func showQRCode() {
        
        // Compose the QR code data of values that shouldn't change over time
        let qrCodeObject = qrCode(
            name: inventoryItem.name,
            description: inventoryItem.description,
            story:inventoryItem.story ?? "",
            category: inventoryItem?.category.description ?? ""
        )
        
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(qrCodeObject)
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
        
        let qrCodeImage = self.generateQRCode(from: jsonString! as String)
        
        if let grayscale = qrCodeImage?.grayscale, let data = grayscale.pngData() {
                let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(inventoryItem.name + ".png")
                try? data.write(to: path!)
                let previewController = QLPreviewController()
                self.previewItem = path! as NSURL
                previewController.dataSource = self
                self.present(previewController, animated: true, completion: nil)
            } else {
                print("qr code image error")
            }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @objc func menuTapped(sender: AnyObject?) {
        var actions: [PopMenuAction] = []
        
        let qrCodeAction = PopMenuDefaultAction(title: "QR Code", color: .white) { _ in
            self.dismiss(animated: true, completion: {
                self.showQRCode()
            })
        }
        actions.append(qrCodeAction)
        
        
        if editAllowed {
            let editAction = PopMenuDefaultAction(title: "Edit", color: .white) { _ in
                self.dismiss(animated: true, completion: {
                    self.presenter.wrapped?.edit()
                })
            }
            actions.append(editAction)
        }
        if deleteAllowed {
            let deleteAction = PopMenuDefaultAction(title: "Delete", color: UIColor(r: 255, g: 56, b: 35)) { _ in
                self.dismiss(animated: true, completion: {
                    self.showDeleteConfirmationAlert()
                })
            }
            actions.append(deleteAction)
        }
        
        let menu = PopMenuViewController(sourceView: sender, actions: actions)
        menu.appearance.popMenuColor.backgroundColor = .solid(fill: UIColor(r: 49, g: 69, b: 92))
        menu.appearance.popMenuCornerRadius = 10
        menu.appearance.popMenuItemSeparator = .fill(.white)
        menu.appearance.popMenuFont = Fonts.font(of: 16, weight: .regular)
        
        present(menu, animated: true, completion: nil)
    }
    
    @objc func voteForItem(sender: Any?) {
        presenter.wrapped?.vote()
    }

    @objc func withdrawVoteFromItem(sender: Any?) {
        presenter.wrapped?.withdrawVote()
    }
    
}

