//
//  WishListScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 5/6/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit
import NVActivityIndicatorView
import WishKit
import FlowKit
import XLPagerTabStrip

class WishListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, ActivityViewProvider, WishListViewProtocol {
    
    var presenter: WeakWrapper<WishListPresenterProtocol> = WeakWrapper()
    var wishes = [Wish]()
    let wishListTableView = UITableView()
    let refreshControl = UIRefreshControl()
    var activity: NVActivityIndicatorView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsStatusBarAppearanceUpdate()
        presenter.wrapped?.reloadWishes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
        
        navigationItem.rightBarButtonItem = BarButtonItem.configured(item:  UIBarButtonItem(title: "New", style: .plain, target: self, action: #selector(onCreateNewWishButtonTapped)))
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        
        wishListTableView.delegate = self
        wishListTableView.dataSource = self
        wishListTableView.register(WishPreviewTableViewCell.self, forCellReuseIdentifier: String(describing: WishPreviewTableViewCell.self))
        wishListTableView.backgroundColor = .clear
        wishListTableView.separatorColor = UIColor(r: 49, g: 69, b: 92)
        wishListTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        container.addSubview(wishListTableView)
        
        wishListTableView.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(container.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom)
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        
        wishListTableView.refreshControl = refreshControl
    }
    
    func showWishes(_ wishes: [Wish]) {
        self.wishes = wishes
        
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            // If refresh control is refreshing, wait till animation ends
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.wishListTableView.reloadData()
            }
        } else {
            self.wishListTableView.reloadData()
        }
    }

    @objc func handleRefresh(sender: Any?) {
        if !wishListTableView.isDragging {
            startWishesFetch()
        }
    }
    
    private func startWishesFetch() {
        presenter.wrapped?.fetchWishes { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    @objc func onCreateNewWishButtonTapped(sender: Any?) {
        presenter.wrapped?.openCreateWishScreen()
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.wrapped?.openDetailsScreen(for: wishes[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            startWishesFetch()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WishPreviewTableViewCell.self), for: indexPath) as! WishPreviewTableViewCell
        cell.customize(with: wishes[indexPath.row])
        
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension WishListScreen: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Wishlist")
    }
    
}
