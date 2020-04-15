//
//  GridView.swift
//  s33d
//
//  Created by Andrii Selivanov on 6/21/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation

struct GridView {
    
    struct LayoutConfiguration {
        let verticalSpacing: CGFloat
        let horizontalSpacing: CGFloat
        
        static let `default` = LayoutConfiguration(verticalSpacing: 16, horizontalSpacing: 8)
    }
    
    static func build(from subviews: [UIView], width: Int, height: Int, configuration: LayoutConfiguration = .default) -> UIView {
        let containerView = UIView()
        subviews.forEach(containerView.addSubview)
        
        for index in 0..<(width * height) {
            let currentView = subviews[index]
            
            currentView.snp.makeConstraints { make in
                if index > 0 {
                    // It's not a first view, so we should add equal height and width constraint related to first view
                    
                    let firstView = subviews[0]
                    make.width.equalTo(firstView)
                    make.height.equalTo(firstView)
                }
                
                if index % width == 0 {
                    // It's a first view in a row, so we add left constraint to container
                    make.left.equalTo(containerView)
                } else {
                    // It's not a first view in a row, so we add left constraint to the view on the left
                    let leftView = subviews[index - 1]
                    
                    make.left.equalTo(leftView.snp.right).offset(configuration.horizontalSpacing)
                }
                
                if index % width == width - 1 {
                    // It's a last view in a row, so we add right constraint to container
                    make.right.equalTo(containerView)
                }
                
                if index / width == 0 {
                    // It's a first row, so we top add constraint to container
                    make.top.equalTo(containerView)
                } else {
                    // It's not a first row, so we add constraint to view on the top
                    let topLabel = subviews[index - width]
                    
                    make.top.equalTo(topLabel.snp.bottom).offset(configuration.verticalSpacing)
                }
                
                if index / width == height - 1 {
                    // It's a last row, so we add bottom constraint to container
                    make.bottom.equalTo(containerView)
                }
                
            }
        }
        
        return containerView
    }
    
}
