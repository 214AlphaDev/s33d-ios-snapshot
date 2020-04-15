//
//  InventoryListScreen.swift
//  s33d
//
//  Created by Andrii Selivanov on 5/26/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import SnapKit
import NVActivityIndicatorView
import InventoryKit
import FlowKit
import XLPagerTabStrip
import QuickLook
import CommunityKit

extension InventoryListScreen: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        
        return self.previewItem as QLPreviewItem
    }
}

class InventoryListScreen: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate, UIDocumentInteractionControllerDelegate, ActivityViewProvider, InventoryListViewProtocol {
   
    lazy var previewItem = NSURL()
    
    var presenter: WeakWrapper<InventoryListPresenterProtocol> = WeakWrapper()
    var inventoryItems = [InventoryItem]()
    let inventoryCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: UICollectionViewFlowLayout())
    let refreshControl = UIRefreshControl()
    var activity: NVActivityIndicatorView?
    var tableViewSafeAreaConstraint: Constraint?
    var tableViewContainerConstraint: Constraint?
    private var createAllowed: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        presenter.wrapped?.reloadInventoryItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        createUI(in: view)
        configureNavigationItem()
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.utf8)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        activity = ActivityIndicator.build(in: container)
        
        inventoryCollectionView.delegate = self
        inventoryCollectionView.dataSource = self
        inventoryCollectionView.register(InventoryItemPreviewCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: InventoryItemPreviewCollectionViewCell.self))
        inventoryCollectionView.backgroundColor = .clear
        inventoryCollectionView.contentInsetAdjustmentBehavior = .never
        container.addSubview(inventoryCollectionView)
        
        inventoryCollectionView.snp.makeConstraints { make -> Void in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            tableViewSafeAreaConstraint = make.top.equalTo(createAllowed ? container.safeAreaLayoutGuide : container).constraint
            tableViewContainerConstraint = make.top.equalTo(createAllowed ? container.safeAreaLayoutGuide : container).constraint
            make.bottom.equalTo(container)
        }
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        
        inventoryCollectionView.refreshControl = refreshControl
    }
    
    func configureNavigationItem() {
        if createAllowed {
            tableViewSafeAreaConstraint?.activate()
            tableViewContainerConstraint?.deactivate()
            navigationItem.rightBarButtonItem = BarButtonItem.configured(item:  UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(onCreateNewInventoryItemButtonTapped)))
            navigationItem.leftBarButtonItem = BarButtonItem.configured(item:  UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(onExportInventoryItemButtonTapped)))
        } else {
            tableViewContainerConstraint?.activate()
            tableViewSafeAreaConstraint?.deactivate()
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func showInventoryItems(_ items: [InventoryItem]) {
        self.inventoryItems = items
      
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
            // If refresh control is refreshing, wait till animation ends
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.inventoryCollectionView.reloadData()
            }
        } else {
            inventoryCollectionView.reloadData()
        }
    }
    
    func setCreateAllowed(_ allowed: Bool) {
        createAllowed = allowed
        configureNavigationItem()
    }

    @objc func handleRefresh(sender: Any?) {
        if !inventoryCollectionView.isDragging {
            startItemsFetch()
        }
    }
    
    private func startItemsFetch() {
        presenter.wrapped?.fetchInventoryItems { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }

    @objc func onCreateNewInventoryItemButtonTapped(sender: Any?) {
        presenter.wrapped?.openCreateInventoryItemScreen()
    }
    
    struct qrCode : Codable {
        let name: String
        let description: String
        let story: String
        let category: String
    }
    
    
    @objc func onExportInventoryItemButtonTapped(sender: Any?) {
    
        let appBundleID = Bundle.main.bundleIdentifier!
        let AppIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
        let keychainAccessGroup = AppIdentifierPrefix + appBundleID
        let keychain = CommunityKitDatabaseFactory.buildKeychain(accessGroup: keychainAccessGroup)
        let accessMaterialRepository = AccessMaterialRepository(keyChain: keychain)
        let accessMaterial = try! accessMaterialRepository.getAccessMaterial()
        
        let inventoryBackend = InventoryBackend(url: Contants.inventoryBackupBackendURL, rawAccessToken: accessMaterial!.accessToken.rawAccessToken)
     
        let activity = ActivityIndicator.build(in: self.view)
        activity.startAnimating()
    
        inventoryBackend.inventoryItems(from: nil, count: 214) { [weak self] response in

            switch response {
            case .failure(let error):
                print(error)
                activity.stopAnimating()
            case .success(let inventoryItems):
            
                var csvText = "Votes,Category,Name,Description,Story,Photo,QRCode\n"
                
                let count = inventoryItems.count
                
                
                
                
                
                if count > 0 {
                    let sortedInventoryItemsArray = self!.sortedInventoryItems(inventoryItems)
                    for item in sortedInventoryItemsArray {
                    
                            // Compose the QR code data of values that shouldn't change over time
                            let qrCodeObject = qrCode(
                                name: item.name,
                                description: item.description,
                                story: item.story ?? "",
                                category: item.category.description
                            )
                        
                        var completeQRCodeImageBase64 = "";
                        let jsonEncoder = JSONEncoder()
                        let jsonData = try! jsonEncoder.encode(qrCodeObject)
                        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)

                        let qrCodeImage = self!.generateQRCode(from: jsonString! as String)
    
                        if let grayscale = qrCodeImage?.grayscale, let data = grayscale.pngData() {
                            completeQRCodeImageBase64 = data.base64EncodedString()
                        } else {
                            print("qr code image error")
                        }
                        
                        let newLine = """
                        "\(item.votes)","\(item.category)","\(item.name)","\(item.description)","\(item.story ?? "")","\(item.photo?.pictureDataString ?? "")","\(completeQRCodeImageBase64)"\n
                        """
                        
                        csvText.append(contentsOf: newLine)
                    }
                    
                    do {
                        
                        let csvHash = csvText.sha256()
                        UIPasteboard.general.string = csvHash
                        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(csvHash + ".csv")
                        try csvText.write(to: path!, atomically: true, encoding: String.Encoding.utf8)
                        
                        let previewController = QLPreviewController()
                        self!.previewItem = path! as NSURL
                        previewController.dataSource = self
                        self!.present(previewController, animated: true, completion: nil)
                        activity.stopAnimating()
                        
                    } catch {
                        activity.stopAnimating()
                        print("Failed to create file")
                        print("\(error)")
                    }
                    
                } else {
                    activity.stopAnimating()
                    print("BAD ERROR")
                }
            }
        }
        
    }
    
    private func sortedInventoryItems(_ items: [InventoryItem]) -> [InventoryItem] {
        return items.sorted(by: { lhs, rhs -> Bool in
            if lhs.votes != rhs.votes {
                return lhs.votes > rhs.votes
            }
            
            return lhs.id.description < rhs.id.description
        })
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: createAllowed ? 8 : 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = (collectionView.bounds.width - 20 * 2 - 12) / 2.0
        return CGSize(width: width, height: width / 156.0 * 217)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.wrapped?.openDetailsScreen(for: inventoryItems[indexPath.row])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshControl.isRefreshing {
            startItemsFetch()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventoryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: InventoryItemPreviewCollectionViewCell.self), for: indexPath) as! InventoryItemPreviewCollectionViewCell
        cell.customize(with: inventoryItems[indexPath.item])
        
        return cell
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

extension InventoryListScreen: IndicatorInfoProvider {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Library")
    }
    
}
