//
//  YourStoryTelegramPlaceholderScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/24/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import FlowKit
import XLPagerTabStrip

// UI is implemented inside the storyboard
class YourStoryTelegramPlaceholderScreen: UIViewController, Presenter {
    
    @IBOutlet weak var linkTextView: UITextView!
    
    override func viewDidLoad() {
        // Make link one line
        linkTextView.textContainer.maximumNumberOfLines = 1
        linkTextView.textContainer.lineBreakMode = .byTruncatingMiddle
        
        // Add underline
        let text = NSMutableAttributedString(attributedString:  linkTextView.attributedText)
        text.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: text.length))
        
        linkTextView.attributedText = text
    }
    
}

extension YourStoryTelegramPlaceholderScreen: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "yOur story")
    }
    
}
