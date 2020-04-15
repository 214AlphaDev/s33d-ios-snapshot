//
//  MeditationScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 4/13/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit

class MeditationScreen: UIViewController {
    let meditation = "The following describes what some might consider an “on the run“ form of meditation.\n\nIt’s a quick, simple, and effective way to gain clarity and peace within a busy world, with intentions for we S33D to discern the best, daily course of action in the weaving of our shared dreams into an expression of oneness, through life-giving diversity.\n\nSit up tall, your shoulders back, and close your eyes.\n\nTake one, two, three deep breaths of pure cleansing air, and in each imagine that you are pulling clear green light from the earth, through your crown chakra, into the depths of your lungs, and throughout your body.\n\nReally take the time to allow these breaths to permeate your body, allowing this clear green light to find the dark, smoky black spots which might have accumulated during times of stress or hurried interaction.\n\nHold each breath, as described, and when you exhale, set intentions for the dark smoky spots to be carried up out of the shadowy extremities, and out of your body, through your mouth.\n\nAllow these smoky clumps of negative energy to flow into the earth so it can cleanse and restore balance.\n\nBy no means are you limited to three breaths. Feel free to continue the exercise, as needed."
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        
        let headerImageView = UIImageView()
        headerImageView.contentMode =  UIView.ContentMode.scaleAspectFill
        headerImageView.clipsToBounds = false
        headerImageView.image = UIImage(named: "banyan_tree_roots.jpg")
        headerImageView.clipsToBounds = true
        headerImageView.alpha = 0.6
        container.addSubview(headerImageView)
        
        let labelTitle = UILabel()
        labelTitle.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelTitle.textAlignment = .center
        labelTitle.sizeToFit()
        labelTitle.font = Fonts.font(of: 20.0, weight: .bold)
        labelTitle.text = "Meditation"
        container.addSubview(labelTitle)
        
        let meditationText = UITextView()
        meditationText.textAlignment = NSTextAlignment.left
        meditationText.backgroundColor = nil
        meditationText.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        meditationText.font = Fonts.font(of: 15, weight: .bold)
        meditationText.isEditable = false
        meditationText.text = meditation
        container.addSubview(meditationText)
        
        headerImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(250)
        }
        labelTitle.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(container.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(container).offset(20)
            make.right.equalTo(container).offset(-20)
        }
        meditationText.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(26)
            make.right.equalTo(container).offset(-26)
            make.top.equalTo(headerImageView.snp.bottom).offset(40)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}
