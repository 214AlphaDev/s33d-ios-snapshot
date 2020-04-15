//
//  InventoryItemCreateScreen.swift
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
import UITextView_Placeholder

class InventoryItemCreateScreen: UIViewController, KeyboardDismissable, UITextViewDelegate, ActivityViewProvider, InventoryItemCreateViewProtocol {
    
    var presenter: WeakWrapper<InventoryItemCreatePresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    let nameTextField = UITextField()
    let descriptionTextView = UITextView()
    let storyTextView = UITextView()
    let photoImageView = UIImageView()
    let imagePickerController = ImagePickerController()
    var submitBarButtonItem: UIBarButtonItem!
    var keyboardView: UIView!
    var categoryPicker: CategoryPicker? {
        didSet {
            categoryPicker?.setCategory(category)
        }
    }
    var category: CategoryPicker.Category = .other {
        didSet {
            categoryPicker?.setCategory(category)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        updateSubmitEnabled()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
        keyboardDismissAction = setupKeyboardDismissRecognizer()
    }
    
    func createUI(in container: UIView) {
        imagePickerController.delegate = self
        
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        let navigationBar = createNavigationBar(in: container)
        
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        container.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(navigationBar.safeAreaLayoutGuide.snp.bottom)
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
        let categoryPickerContainer = UIView()
        categoryPickerContainer.backgroundColor = .clear
        container.addSubview(categoryPickerContainer)
        categoryPicker = CategoryPicker.build(in: categoryPickerContainer)
        categoryPicker?.didSelectCategory = { [weak self] category in
            self?.presenter.wrapped?.setCategory(category.inventoryCategory)
        }
        presenter.wrapped?.setCategory(CategoryPicker.Category.other.inventoryCategory)
        
        let photoContainer = createPhotoContainer(in: container)
        
        let clearPhotoButton = Button.build(style: .transparent)
        clearPhotoButton.addTarget(self, action: #selector(clearPhotoTapped), for: .touchUpInside)
        clearPhotoButton.setTitle("Clear photo", for: .normal)
        clearPhotoButton.layer.borderWidth = 0
        container.addSubview(clearPhotoButton)
        
        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)])
        nameTextField.borderStyle = UITextField.BorderStyle.none
        nameTextField.backgroundColor = nil
        nameTextField.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        nameTextField.keyboardType = UIKeyboardType.default
        nameTextField.font = Fonts.font(of: 22, weight: .bold)
        nameTextField.addTarget(self, action: #selector(nameChanged), for: .editingChanged)
        container.addSubview(nameTextField)
        
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.75)
        descriptionLabel.font = Fonts.font(of: 16, weight: .medium)
        descriptionLabel.text = "Description"
        container.addSubview(descriptionLabel)
        
        descriptionTextView.delegate = self
        descriptionTextView.textAlignment = NSTextAlignment.justified
        descriptionTextView.backgroundColor = nil
        descriptionTextView.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        descriptionTextView.font = Fonts.font(of: 18, weight: .regular)
        descriptionTextView.keyboardType = UIKeyboardType.default
        descriptionTextView.textContainer.lineFragmentPadding = 0
        descriptionTextView.textContainerInset = UIEdgeInsets()
        descriptionTextView.placeholder = "What is this product? (at least 30 characters)"
        descriptionTextView.placeholderColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)
        container.addSubview(descriptionTextView)
        
        let storyLabel = UILabel()
        storyLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.75)
        storyLabel.font = Fonts.font(of: 16, weight: .medium)
        storyLabel.text = "Story"
        container.addSubview(storyLabel)
        
        storyTextView.delegate = self
        storyTextView.textAlignment = NSTextAlignment.justified
        storyTextView.backgroundColor = nil
        storyTextView.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        storyTextView.font = Fonts.font(of: 18, weight: .regular)
        storyTextView.keyboardType = UIKeyboardType.default
        storyTextView.textContainer.lineFragmentPadding = 0
        storyTextView.textContainerInset = UIEdgeInsets()
        storyTextView.placeholder = "What is the origin of this product? (leave empty or put at least 20 characters)"
        storyTextView.placeholderColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.5)
        container.addSubview(storyTextView)
        
        photoContainer.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(container).offset(22)
            make.height.equalTo(160)
            make.width.equalTo(160)
        }
        
        clearPhotoButton.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(photoContainer.snp.bottom).offset(8)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(clearPhotoButton.snp.bottom).offset(32)
        }
        
        LineSeparator.build(in: container).snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.right.equalTo(nameTextField)
            make.top.equalTo(nameTextField.snp.bottom).offset(3)
        }
        
        categoryPickerContainer.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(nameTextField.snp.bottom).offset(22)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionTextView)
            make.right.equalTo(descriptionTextView)
            make.top.equalTo(categoryPickerContainer.snp.bottom).offset(22)
        }
        
        descriptionTextView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
        }
        
        LineSeparator.build(in: container).snp.makeConstraints { make in
            make.left.equalTo(descriptionTextView)
            make.right.equalTo(descriptionTextView)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(3)
        }
        
        storyLabel.snp.makeConstraints { make in
            make.left.equalTo(storyTextView)
            make.right.equalTo(storyTextView)
            make.top.equalTo(descriptionTextView.snp.bottom).offset(40)
        }
        
        storyTextView.snp.makeConstraints { make in
            make.height.equalTo(200)
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(storyLabel.snp.bottom).offset(5)
        }
        
        LineSeparator.build(in: container).snp.makeConstraints { make in
            make.left.equalTo(storyTextView)
            make.right.equalTo(storyTextView)
            make.top.equalTo(storyTextView.snp.bottom)
        }
        
        let keyboardView = UIView()
        keyboardView.isHidden = true
        container.addSubview(keyboardView)
        
        keyboardView.snp.makeConstraints { make in
            make.height.equalTo(0)
            make.top.equalTo(storyTextView.snp.bottom).offset(36)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.keyboardView = keyboardView
    }
    
    func createPhotoContainer(in container: UIView) -> UIView {
        let photoContainer = UIView()
        photoContainer.clipsToBounds = true
        photoContainer.layer.borderWidth = 0.5
        photoContainer.layer.cornerRadius = 5
        photoContainer.layer.borderColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor).cgColor
        container.addSubview(photoContainer)
        
        photoImageView.clipsToBounds = true
        photoImageView.contentMode = .scaleAspectFit
        photoContainer.addSubview(photoImageView)
        
        let changePhotoButton = Button.build(style: .icon(UIImage(named: Contants.marketplaceCreateScreenPhotoIcon)!))
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        photoContainer.addSubview(changePhotoButton)
        
        photoImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        changePhotoButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return photoContainer
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
        
        let cancelItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        
        let submitItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(submitTapped))
        
        submitBarButtonItem = submitItem
        
        let navigationItem = UINavigationItem(title: "New Item")
        navigationItem.leftBarButtonItem = BarButtonItem.configured(item: cancelItem)
        navigationItem.rightBarButtonItem = BarButtonItem.configured(item: submitItem)
        
        navigationBar.items = [navigationItem]
        
        return navigationBar
    }
    
    @objc func clearPhotoTapped(sender: Any?) {
        presenter.wrapped?.setItemPhoto(nil)
        photoImageView.image = nil
    }
    
    @objc func changePhotoTapped(sender: Any?) {
        imagePickerController.showPicker(from: self)
    }
    
    @objc func cancelTapped(sender: Any?) {
        presenter.wrapped?.cancel()
    }
    
    @objc func submitTapped(sender: Any?) {
        presenter.wrapped?.submit()
    }
    
    @objc func nameChanged(sender: Any?) {
        presenter.wrapped?.setName(nameTextField.text ?? "")
        updateSubmitEnabled()
    }
    
    func setDraft(_ draft: CreatingInventoryItem) {

        category = CategoryPicker.Category(inventoryCategory: draft.category)
        nameTextField.text = draft.name
        descriptionTextView.text = draft.description
        storyTextView.text = draft.story
        photoImageView.image = draft.photo?.picture
        
        updateSubmitEnabled()
    }
    
    // MARK: Validation
    
    func updateSubmitEnabled() {
        let name = nameTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        let story = storyTextView.text.isEmpty ? nil : (storyTextView.text ?? "")
        
        if case .some(.invalid) = presenter.wrapped?.validate(field: .name(name))  {
            submitBarButtonItem.isEnabled = false
        } else if case .some(.invalid) = presenter.wrapped?.validate(field: .description(description))  {
            submitBarButtonItem.isEnabled = false
        } else if case .some(.invalid) = presenter.wrapped?.validate(field: .story(story))  {
            submitBarButtonItem.isEnabled = false
        } else {
            submitBarButtonItem.isEnabled = true
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === descriptionTextView {
            presenter.wrapped?.setDescription(textView.text)
        }
        if textView === storyTextView {
            presenter.wrapped?.setStory(textView.text.isEmpty ? nil : textView.text)
        }
        updateSubmitEnabled()
    }
    
    // MARK: Keyboard
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let info = notification.userInfo else { return }
        guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = frameInfo.cgRectValue
        
        UIView.animate(withDuration: 0.3) {
            self.keyboardView.snp.updateConstraints { make in
                make.height.equalTo(keyboardFrame.height)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.keyboardView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            self.view.layoutIfNeeded()
        }
    }
    
}

extension InventoryItemCreateScreen: ImagePickerControllerDelegate {
    func imagePickerController(_ controller: ImagePickerController, imageSelected image: UIImage) {
        let compressedImage = UIImage(data: ImageCompressor.compressedData(image))
        photoImageView.image = compressedImage
        presenter.wrapped?.setItemPhoto(compressedImage)
    }
    
}
