//
//  ImagePickerController.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/27/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import Fusuma

protocol ImagePickerControllerDelegate: class {
    
    func imagePickerController(_ controller: ImagePickerController, imageSelected image: UIImage)
    
}

class ImagePickerController: FusumaDelegate {
    
    let fusuma = FusumaViewController()
    public weak var delegate: ImagePickerControllerDelegate?
    
    init() {
        fusuma.delegate = self
        fusuma.availableModes = [FusumaMode.library, FusumaMode.camera]
        fusuma.allowMultipleSelection = false
        fusumaBackgroundColor = UIColor.black
        fusumaBaseTintColor = UIColor.lightGray
        fusumaTintColor = UIColor.white
    }
    
    func showPicker(from vc: UIViewController) {
        vc.present(fusuma, animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        delegate?.imagePickerController(self, imageSelected: image)
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) { }
    
    func fusumaCameraRollUnauthorized() {}
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {}
    
}
