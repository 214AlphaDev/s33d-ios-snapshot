//
//  MemberVerificationApplicationStatusScreen.swift
//  s33d
//
//  Created by Alberto R. Estarrona on 3/25/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import UIKit
import SnapKit
import CommunityKit
import NVActivityIndicatorView
import FlowKit

class MemberVerificationApplicationStatusScreen: UIViewController, MemberVerificationStatusViewProtocol, ActivityViewProvider {
    var presenter: WeakWrapper<MemberVerificationStatusPresenterProtocol> = WeakWrapper()
    
    var activity: NVActivityIndicatorView?
    let labelApplicationText = UILabel()
    let verifyMembershipButton = Button.build(style: .solid)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        // TODO: Disallow go back in more stable way
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI(in: view)
    }
    
    func createUI(in container: UIView) {
        Background.build(in: container)
        let logoView = Logo.build(in: container, height: 170, bottomOffset: 210)
        activity = ActivityIndicator.build(in: container)
        
        labelApplicationText.textColor = UIColor.init(hexFromString: Contants.globalWhitelabelColor)
        labelApplicationText.textAlignment = .center
        labelApplicationText.numberOfLines = 0
        labelApplicationText.adjustsFontSizeToFitWidth = true
        labelApplicationText.minimumScaleFactor=0.5;
        labelApplicationText.font = Fonts.font(of: 20.0, weight: .regular)
        labelApplicationText.text = "Your application will be processed soon.\n\n Thanks for your patience."
        container.addSubview(labelApplicationText)
        
        verifyMembershipButton.addTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
        verifyMembershipButton.setTitle("Review Status", for: .normal)
        container.addSubview(verifyMembershipButton)
        
        labelApplicationText.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.top.equalTo(logoView.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.bottom.equalTo(verifyMembershipButton.safeAreaLayoutGuide.snp.top).offset(-5)
        }
        verifyMembershipButton.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(container).offset(30)
            make.right.equalTo(container).offset(-30)
            make.bottom.equalTo(container.safeAreaLayoutGuide.snp.bottom).offset(-30)
        }
    }
    
    @objc func refreshStatus(sender:UIButton!) {
        presenter.wrapped?.updateStatus()
    }
    
    @objc func goToMainApp(sender:UIButton!) {
        presenter.wrapped?.goToMainApp()
    }
    
    @objc func goToSendApplication(sender:UIButton!) {
        presenter.wrapped?.goToSendApplication()
    }
    
    // MARK: MemberVerificationStatusViewProtocol
    
    func showApplicationState(_ state: MemberVerificationApplication.State) {
        switch state {
        case .rejected:
            labelApplicationText.text = "Your application has been rejected.\n\n You can update your information and resubmit in case you think this may be an error."
            verifyMembershipButton.setTitle("Resend Application", for: .normal)
            verifyMembershipButton.removeTarget(self, action: #selector(goToMainApp), for: .touchUpInside)
            verifyMembershipButton.removeTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
            verifyMembershipButton.addTarget(self, action: #selector(goToSendApplication), for: .touchUpInside)
        case .approved:
            labelApplicationText.text = Contants.applicationApprovedText
            verifyMembershipButton.setTitle(Contants.applicationApprovedButtonText, for: .normal)
            verifyMembershipButton.removeTarget(self, action: #selector(goToSendApplication), for: .touchUpInside)
            verifyMembershipButton.removeTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
            verifyMembershipButton.addTarget(self, action: #selector(goToMainApp), for: .touchUpInside)
        case .pending:
            labelApplicationText.text = "Your application will be processed soon.\n\n Thanks for your patience."
            verifyMembershipButton.setTitle("Review Status", for: .normal)
            verifyMembershipButton.removeTarget(self, action: #selector(goToSendApplication), for: .touchUpInside)
            verifyMembershipButton.removeTarget(self, action: #selector(goToMainApp), for: .touchUpInside)
            verifyMembershipButton.addTarget(self, action: #selector(refreshStatus), for: .touchUpInside)
        }
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
