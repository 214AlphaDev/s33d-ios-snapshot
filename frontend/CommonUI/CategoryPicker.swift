//
//  CategoryPicker.swift
//  s33d
//
//  Created by Andrii Selivanov on 7/23/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit

class CategoryPicker: NSObject {
    
    enum Category {
        case book
        case seed
        case other
        
        var icon: UIImage {
            switch self {
            case .book:
                return UIImage(named: "book-category-icon")!
            case .seed:
                return UIImage(named: "seed-category-icon")!
            case .other:
                return UIImage(named: "other-category-icon")!
            }
        }
        var name: String {
            switch self {
            case .book:
                return "Book"
            case .seed:
                return "Seed"
            case .other:
                return "Other"
            }
        }
        
        static let all: [Category] = [.book, .seed, .other]
    }
    
    struct Configuration {
        
        let title: String
        let categories: [Category]
        
        static let `default` = Configuration(title: "Item Type", categories: Category.all)
    }
    
    private(set) var selectedCategoryIndex: Int {
        didSet {
            if let category = categories[safe: selectedCategoryIndex] {
                selectedCategoryImageView.image = category.icon
                selectedCategoryNameLabel.text = category.name
                pickerView.selectRow(selectedCategoryIndex, inComponent: 0, animated: true)
                didSelectCategory(category)
            }
        }
    }
    private let categories: [Category]
    private let selectedCategoryImageView: UIImageView
    private let selectedCategoryNameLabel: UILabel
    private let fakeTextField: UITextField
    private let pickerView: UIPickerView
    public var didSelectCategory: (Category) -> Void = { _ in }
    
    init(categories: [Category], selectedCategoryIndex: Int, selectedCategoryImageView: UIImageView, selectedCategoryNameLabel: UILabel, selectedCategoryView: UIView, pickerView: UIPickerView) {
        self.categories = categories
        self.selectedCategoryIndex = selectedCategoryIndex
        self.selectedCategoryImageView = selectedCategoryImageView
        self.selectedCategoryNameLabel = selectedCategoryNameLabel
        self.fakeTextField = UITextField()
        self.pickerView = pickerView
        
        super.init()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        fakeTextField.inputView = pickerView
        selectedCategoryView.addSubview(fakeTextField)
        
        let selectedViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectedViewTapped))
        selectedCategoryView.addGestureRecognizer(selectedViewTapGestureRecognizer)
    }
    
    func setCategory(_ category: Category) {
        guard let index = categories.firstIndex(where: { c -> Bool in
            // TODO: Change comparison by name to something more stable
            return c.name == category.name
        }) else {
            return
        }
        
        selectedCategoryIndex = index
    }
    
    @objc func selectedViewTapped(sender: Any?) {
        fakeTextField.becomeFirstResponder()
    }
    
    static func build(in container: UIView, configuration: Configuration = .default) -> CategoryPicker {
        let captionLabel = UILabel()
        captionLabel.text = configuration.title
        captionLabel.textColor = UIColor(white: CGFloat(Contants.globalLineSeparatorBackgroundColorWhiteAmount), alpha: 0.75)
        captionLabel.font = Fonts.font(of: 16, weight: .medium)
        captionLabel.textAlignment = .left
        container.addSubview(captionLabel)
        
        let selectedCategoryView = UIView()
        selectedCategoryView.backgroundColor = .clear
        selectedCategoryView.borderWidth = 1
        selectedCategoryView.borderUIColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        selectedCategoryView.cornerRadius = 5
        container.addSubview(selectedCategoryView)
        
        captionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        selectedCategoryView.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(captionLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        let selectedCategoryImageView = UIImageView()
        selectedCategoryView.addSubview(selectedCategoryImageView)
        
        let selectedCategoryNameLabel = UILabel()
        selectedCategoryNameLabel.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        selectedCategoryNameLabel.font = Fonts.font(of: 18, weight: .medium)
        selectedCategoryNameLabel.textAlignment = .left
        selectedCategoryView.addSubview(selectedCategoryNameLabel)
        
        selectedCategoryImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(32)
            make.width.equalTo(32)
            make.left.equalTo(32)
        }
        
        selectedCategoryNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.equalTo(selectedCategoryImageView.snp.right).offset(32)
            make.right.equalToSuperview()
        }
        
        let pickerView = UIPickerView()
        pickerView.backgroundColor = UIColor(r: 35, g: 53, b: 74)
        
        return CategoryPicker(categories: configuration.categories, selectedCategoryIndex: 0, selectedCategoryImageView: selectedCategoryImageView, selectedCategoryNameLabel: selectedCategoryNameLabel, selectedCategoryView: selectedCategoryView, pickerView: pickerView)
    }
    
}

extension CategoryPicker: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedCategoryIndex = row
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSMutableAttributedString(string: categories[safe: row]?.name ?? "Unknown")
        title.addAttribute(.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: title.length))
        title.addAttribute(.font, value: Fonts.font(of: 18, weight: .medium), range: NSRange(location: 0, length: title.length))
        
        return title
    }
    
}

extension CategoryPicker: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
}
