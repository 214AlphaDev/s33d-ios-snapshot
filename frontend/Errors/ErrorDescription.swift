//
//  ErrorDescription.swift
//  s33d
//
//  Created by Andrii Selivanov on 3/15/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import CommunityKit
import WishKit
import InventoryKit
import WalletKit

struct ErrorDescription {
    
    static func describe(error: Error) -> String {
        if let communityKitDescription = CommunityKit.ErrorDescription.describe(error: error) {
            return communityKitDescription
        }
        if let wishKitDescription = WishKit.ErrorDescription.describe(error: error) {
            return wishKitDescription
        }
        if let inventoryKitDescription = InventoryKit.ErrorDescription.describe(error: error) {
            return inventoryKitDescription
        }
        if let walletKitDescription = WalletKit.ErrorDescription.describe(error: error) {
            return walletKitDescription
        }
        // TODO: Add check for desciptions from other SDKs as well
        
        return "Something went wrong"
    }
    
}
