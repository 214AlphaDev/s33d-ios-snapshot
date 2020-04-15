//
//  Utils.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/15/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import InventoryKit
import CommunityKit

func presentError(controller: UIViewController, title: String, error: Error) {
    let alertCtrl = UIAlertController(title: title, message: ErrorDescription.describe(error: error), preferredStyle: .alert)
    alertCtrl.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
    controller.present(alertCtrl, animated: true)
}

func presentAlert(controller: UIViewController, title: String, message: String, configurator: ((UIAlertController) -> Void)? = nil) {
    let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if let configurator = configurator {
        configurator(alertCtrl)
    } else {
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
    controller.present(alertCtrl, animated: true)
}

enum DeviceKind {
    case iPhone5
    // Add more cases if needed
}
    
func device(is kind: DeviceKind) ->Bool {
    switch kind {
        case .iPhone5: return UIScreen.main.nativeBounds.height == Contants.iPhone5Height
    }
}

extension UIColor {
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
}

extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        var newImage: UIImage?
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(cgImage, in: newRect)
            if let img = context.makeImage() {
                newImage = UIImage(cgImage: img)
            }
            UIGraphicsEndImageContext()
        }
        return newImage
    }
}

extension UIImage {
    var grayscale: UIImage? {
        guard let ciImage = ciImage?.applyingFilter("CIColorControls", parameters: [kCIInputSaturationKey: 0]) else { return nil }
        return UIGraphicsImageRenderer(size: size, format: imageRendererFormat).image { _ in
            UIImage(ciImage: ciImage).draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension String {
    
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}
