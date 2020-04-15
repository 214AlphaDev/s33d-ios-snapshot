//
//  ApplicationsListScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/31/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation

import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit
import XLPagerTabStrip

class ApplicationsListScreen: UIViewController, ApplicationsListViewProtocol, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ActivityViewProvider {
    
    var presenter: WeakWrapper<ApplicationsListPresenterProtocol> = WeakWrapper()
    var applications = [MemberApplicationViewData]()
    let applicationsTableView = UITableView()
    private let applicationPreviewCellIdentifier = "ApplicationPreviewCellIdentifier"
    let refreshControl = UIRefreshControl()
    var activity: NVActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        presenter.wrapped?.reloadApplications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Contants.applicationListTitle
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        
        applicationsTableView.delegate = self
        applicationsTableView.dataSource = self
        applicationsTableView.register(ApplicationPreviewTableViewCell.self, forCellReuseIdentifier: applicationPreviewCellIdentifier)
        applicationsTableView.backgroundColor = UIColor.init(hexFromString: Contants.globalTabBarTintColor)
        applicationsTableView.separatorColor = UIColor(r: 111, g: 133, b: 158)
        applicationsTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        container.addSubview(applicationsTableView)

        applicationsTableView.snp.makeConstraints { make -> Void in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        
        applicationsTableView.refreshControl = refreshControl
    }

    func showApplications(_ applications: [MemberApplicationViewData]) {
        self.applications = applications
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            // If refresh control is refreshing, wait till animation ends
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.applicationsTableView.reloadData()
            }
        } else {
            applicationsTableView.reloadData()
        }
    }
    
    @objc func handleRefresh(sender: Any?) {
        if !applicationsTableView.isDragging {
            startApplicationsFetch()
        }
    }
    
    private func startApplicationsFetch() {
        presenter.wrapped?.fetchApplications()
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        refreshControl.endRefreshing()
        
        super.present(viewControllerToPresent, animated: true, completion: completion)
    }
    
    // MARK: UITableViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            startApplicationsFetch()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.wrapped?.openDetails(for: applications[indexPath.row].application)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return applications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: applicationPreviewCellIdentifier, for: indexPath) as! ApplicationPreviewTableViewCell
        cell.customize(with: applications[indexPath.row])
        
        return cell
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

extension ApplicationsListScreen: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Administration")
    }
}
