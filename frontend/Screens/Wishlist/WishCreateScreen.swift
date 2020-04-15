//
//  WishCreateScreen.swift
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
import UITextView_Placeholder

class WishCreateScreen: UIViewController, KeyboardDismissable, UITextViewDelegate, ActivityViewProvider, WishCreateViewProtocol {
    
    var presenter: WeakWrapper<WishCreatePresenterProtocol> = WeakWrapper()
    var activity: NVActivityIndicatorView?
    var keyboardDismissAction: SelectorWrapper?
    let nameTextField = UITextField()
    let descriptionTextView = UITextView()
    let storyTextView = UITextView()
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
            self?.presenter.wrapped?.setCategory(category.wishCategory)
        }
        presenter.wrapped?.setCategory(CategoryPicker.Category.other.wishCategory)
        
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
        
//        Story (empty or at least 20 characters)
        
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
        
        categoryPickerContainer.snp.makeConstraints { make in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(container).offset(16)
        }
        
        nameTextField.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(categoryPickerContainer.snp.bottom).offset(40)
        }
        
        LineSeparator.build(in: container).snp.makeConstraints { make in
            make.left.equalTo(nameTextField)
            make.right.equalTo(nameTextField)
            make.top.equalTo(nameTextField.snp.bottom).offset(3)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalTo(descriptionTextView)
            make.right.equalTo(descriptionTextView)
            make.top.equalTo(nameTextField.snp.bottom).offset(40)
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
    
    func setDraft(_ draft: CreatingWish) {
        nameTextField.text = draft.name
        descriptionTextView.text = draft.description
        storyTextView.text = draft.story
        category = CategoryPicker.Category(wishCategory: draft.category)
        
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
