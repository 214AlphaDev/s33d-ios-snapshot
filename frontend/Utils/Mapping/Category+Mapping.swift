//
//  Category+Mapping.swift
//  s33d
//
//  Created by Andrii Selivanov on 8/25/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import WishKit
import InventoryKit

extension CategoryPicker.Category {
    
    init(wishCategory: WishCategory) {
        switch wishCategory.kind {
        case .book:
            self = .book
        case .seed:
            self = .seed
        case .other:
            self = .other
        }
    }
    
    var wishCategory: WishCategory {
        switch self {
        case .book:
            return WishCategory(kind: .book)
        case .seed:
            return WishCategory(kind: .seed)
        case .other:
            return WishCategory(kind: .other)
        }
    }
    
    init(inventoryCategory: InventoryCategory) {
        switch inventoryCategory.kind {
        case .book:
            self = .book
        case .seed:
            self = .seed
        case .other:
            self = .other
        }
    }
    
    var inventoryCategory: InventoryCategory {
        switch self {
        case .book:
            return InventoryCategory(kind: .book)
        case .seed:
            return InventoryCategory(kind: .seed)
        case .other:
            return InventoryCategory(kind: .other)
        }
    }
    
}

