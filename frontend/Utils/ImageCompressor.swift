//
//  ImageCompressor.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/27/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import UIKit.UIImage

class ImageCompressor {
    
    struct CompressConfiguration {
        enum ScaleMode {
            case aspectFit
            case aspectFill
            
            func scale(for size: CGSize, maxSize: CGSize) -> CGFloat {
                switch self {
                case .aspectFit:
                    return min(maxSize.height / size.height, maxSize.width / size.width, 1)
                case .aspectFill:
                    return min(max(maxSize.height / size.height, maxSize.width / size.width), 1)
                }
            }
        }
        
        let maxSize: CGSize
        let quality: CGFloat
        let scaleMode: ScaleMode
        
        static let `default` = CompressConfiguration(maxSize: CGSize(width: 500, height: 500), quality: 0.4, scaleMode: .aspectFit)
    }
    
    static func compressedData(_ image: UIImage, configuration: CompressConfiguration = .default) -> Data {
        return autoreleasepool {
            let maxSize = configuration.maxSize
            let quality = configuration.quality
            let scaledImage = self.scaledImage(image, forMaxSize: maxSize, scaleMode: configuration.scaleMode)
            
            return scaledImage.jpegData(compressionQuality: quality)!
        }
    }
    
    static func scaledImage(_ image: UIImage, forMaxSize maxSize: CGSize, scaleMode: CompressConfiguration.ScaleMode) -> UIImage {
        let scale = scaleMode.scale(for: image.size, maxSize: maxSize)
        let scaledSize = CGSize(width: scale * image.size.width, height: scale * image.size.height)
        
        UIGraphicsBeginImageContext(scaledSize)
        image.draw(in: CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
