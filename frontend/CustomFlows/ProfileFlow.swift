//
//  HomeFlow.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/28/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import FlowKit
import XLPagerTabStrip

struct ProfileItem {
    
    let flow: Flow
    // Title sadly should be provided by view controller itself
    
}

/// Flow that shows pager with subflows.
class ProfileFlow: BaseFlow {
    
    /// Root pager controller
    public let pagerController: ProfilePagerScreen
    /// Array of items which are shown under the pager.
    public let profileItems: [PagerItem]
    
    public init(profileItems: [PagerItem]) {
        self.pagerController = UIStoryboard(name: "ProfilePager", bundle: nil).instantiateInitialViewController() as! ProfilePagerScreen
        self.profileItems = profileItems
        
        super.init()
        
        self.pagerController.datasource = self
        profileItems.forEach {
            $0.flow.nextActionHandler = WeakWrapper(self)
        }
    }
    
    override open func prepareToStart() {
        profileItems
            .forEach { $0.flow.prepareToStart() }
    }
    
    override open func rootViewController() -> UIViewController {
        return pagerController
    }
    
}

extension ProfileFlow: PagerTabStripDataSource {
    
    func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return profileItems.map { $0.flow.rootViewController() }
    }
    
}

