//
//  KeyboardHandler.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/11/19.
//  Copyright © 2019 214alpha. All rights reserved.
//

import UIKit

protocol KeyboardHandlerDelegate: class {
    
    func keyboardWillHide()
    func keyboardWasHide()
    func keyboardWillChangeHeight(_ toHeight: CGFloat, withDuration duration: Double)
    
}

extension KeyboardHandlerDelegate {
    
    func keyboardWillHide() {}
    func keyboardWasHide() {}
    func keyboardWillChangeHeight(_ toHeight: CGFloat, withDuration duration: Double) {}
    
}

class KeyboardHandler: NSObject {
    
    @IBInspectable var dismissOnTouchOutside: Bool = true
    fileprivate var keyboardHeight: CGFloat = 0 {
        didSet {
            heightConstraint?.constant = keyboardHeight
        }
    }
    
    // MARK: IBOutlets
    
    weak var delegate: KeyboardHandlerDelegate?
    @IBOutlet var responderViews: [UIView]!
    @IBOutlet var touchIgnoredViews: [UIView]!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var rootView: UIView! {
        didSet {
            if rootView == nil {
                return
            }
            if dismissOnTouchOutside {
                let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapOutside))
                recognizer.delegate = self
                recognizer.cancelsTouchesInView = false
                rootView.addGestureRecognizer(recognizer)
            }
        }
    }
    var layoutView: UIView?
    var editingView: UIView?
    var keyboardIsOpened: Bool {
        return keyboardHeight != 0
    }
    var isEnabled: Bool = true
    var margin: CGFloat = 16.0
    
    // MARK: Init
    
    override init() {
        super.init()
        
        self.enableNotifications()
    }
    
    deinit {
        self.disableNotifications()
    }
    
    // MARK: Keyboard Notifications
    
    fileprivate func enableNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    fileprivate func disableNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        guard isEnabled else {
            return
        }
        
        delegate?.keyboardWillHide()
    }
    
    @objc fileprivate func keyboardDidHide(_ notification: Notification) {
        guard isEnabled else {
            return
        }
        
        delegate?.keyboardWasHide()
    }
    
    @objc fileprivate func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard isEnabled else {
            return
        }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        inputViewWillChangeFrame(to: endFrame, duration: animationDuration)
    }
    
    func inputViewWillChangeFrame(to endFrame: CGRect, duration: TimeInterval) {
        (layoutView ?? rootView)?.layoutIfNeeded()
        
        keyboardHeight = visibleKeyboardRectangleWithFrame(endFrame).height
        delegate?.keyboardWillChangeHeight(keyboardHeight, withDuration: duration)
        
        updateOffset(duration: duration)
        UIView.animate(
            withDuration: duration,
            animations: {
                (self.layoutView ?? self.rootView)?.layoutIfNeeded()
        },
            completion: nil)
    }
    
    func updateOffset(duration: Double = 0) {
        UIView.animate(withDuration: duration, animations: { 
            self.offsetUpdate()?()
        }) 
    }
    
    fileprivate func offsetUpdate() -> (() -> Void)? {
        if let firstResponder = firstResponderView() {
            return {
                guard let firstResponderRectangle = firstResponder.superview?.convert(firstResponder.frame, to: self.scrollView) else {
                    return
                }
                
                let marginedRectangle = self.addMargins(firstResponderRectangle)
                
                let visibleRectangle = self.rootView.superview!.convert(self.visibleAreaRectangle(), to: self.scrollView)
                self.scrollView.contentOffset.y += self.distanceForRect(marginedRectangle, toBecomeVisibleInRect: visibleRectangle) ?? 0
            }
        }
        
        return nil
    }
    
    // MARK: First responder
    
    fileprivate func firstResponderView() -> UIView? {
        guard responderViews != nil else {
            return nil
        }
        
        for responder in responderViews {
            if responder.isFirstResponder {
                return responder
            }
        }
        
        return nil
    }
    
    
    // MARK: Calculations
    
    private func addMargins(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height + margin)
    }
    
    fileprivate func distanceForRect(_ rect: CGRect, toBecomeVisibleInRect parentRect:CGRect) -> CGFloat? {
        if parentRect.contains(rect) {
            return 0
        }
        if rect.maxY > parentRect.minY {
            return rect.maxY - parentRect.maxY
        }
        
        return 0
    }
    
    fileprivate func visibleAreaRectangle() -> CGRect {
        var visibleRectangle = rootView.frame
        visibleRectangle.size.height -= keyboardHeight
        
        return visibleRectangle
    }
    
    fileprivate func visibleKeyboardRectangleWithFrame(_ frame: CGRect) -> CGRect {
        var visibleRect = frame
        visibleRect.size.height -= max(0, frame.maxY - UIScreen.main.bounds.height)
        
        return visibleRect
    }
    
    // MARK: Tap outside
    
    @objc fileprivate func tapOutside() {
        guard isEnabled else {
            return
        }
        
        (editingView ?? rootView).endEditing(true)
    }
    
}

extension KeyboardHandler: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchIgnoredViews = touchIgnoredViews else {
            return true
        }
        
        for view in touchIgnoredViews {
            if view.bounds.contains(touch.location(in: view)) {
                return false
            }
        }
        
        return true
    }
    
}
