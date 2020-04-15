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

struct PagerItem {
    
    let flow: Flow
    // Title sadly should be provided by view controller itself
    
}

/// Flow that shows pager with subflows.
class HomeFlow: BaseFlow {
    
    /// Root pager controller
    public let pagerController: HomePagerScreen
    /// Array of items which are shown under the pager.
    public let pagerItems: [PagerItem]
    
    public init(pagerItems: [PagerItem]) {
        self.pagerController = UIStoryboard(name: "HomePager", bundle: nil).instantiateInitialViewController() as! HomePagerScreen
        self.pagerItems = pagerItems
        
        super.init()
        
        self.pagerController.datasource = self
        pagerItems.forEach {
            $0.flow.nextActionHandler = WeakWrapper(self)
        }
    }
    
    override open func prepareToStart() {
        pagerItems
            .forEach { $0.flow.prepareToStart() }
    }
    
    override open func rootViewController() -> UIViewController {
        return pagerController
    }
    
}

extension HomeFlow: PagerTabStripDataSource {
    
    func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        return pagerItems.map { $0.flow.rootViewController() }
    }
    
}

// Required for pager to work, because root view controller of flows can be navigation controller
// MARK: - IndicatorInfoProvider
extension DefaultNavigationController: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        guard let root = viewControllers.first, let provider = root as? IndicatorInfoProvider else {
            return IndicatorInfo(title: "Unknown tab")
        }
        
        return provider.indicatorInfo(for: pagerTabStripController)
    }
    
}
