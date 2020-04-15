//
//  MeditationFlow.swift
//  s33d
//
//  Created by Andrii Selivanov on 4/15/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import CommunityKit
import FlowKit

class MeditationFlow: BaseFlow {
    
    let screen = MeditationScreen()
    let memberVerificationService: MemberVerificationServiceProtocol
    
    init(memberVerificationService: MemberVerificationServiceProtocol) {
        self.memberVerificationService = memberVerificationService
    }
    
    override func rootViewController() -> UIViewController {
        return screen
    }
    
}
