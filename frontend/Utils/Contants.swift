//
//  swift
//  s33d
//
//  Created by Andrii Selivanov on 3/15/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import web3swift
import CommunityKit

var bundleIdentiferParts =  Bundle.main.bundleIdentifier!.components(separatedBy: "-")

let whitelabelPlistFileName = "whitelabel-" + bundleIdentiferParts[0]

internal var AppWhitelabelConfig:[String:Any]? {
    if let path = Bundle.main.path(forResource: whitelabelPlistFileName, ofType: "plist") {
        if let dict = NSDictionary(contentsOfFile: path) as? [String:Any] {
            if let UIAppearanceFontDict  =  dict["CONFIG"] as? [String:Any] {
                return UIAppearanceFontDict
            }
        }
    }
    return nil;
}

struct Contants {
    static let window = UIWindow()
    static let appBundleID = Bundle.main.bundleIdentifier!
    static let AppIdentifierPrefix = Bundle.main.object(forInfoDictionaryKey: "AppIdentifierPrefix") as! String
    static let keychainAccessGroup = AppIdentifierPrefix + appBundleID
    static let keychain = CommunityKitDatabaseFactory.buildKeychain(accessGroup: keychainAccessGroup)
    static var applicationRoot: ApplicationRoot!
    //let keychain = CommunityKitDatabaseFactory.buildKeychain(accessGroup: "M9DNN2CU7C.life.s33d.s33d")
    static let accessMaterialRepository = AccessMaterialRepository(keyChain: keychain)
    static var loginBackend = LoginBackend(url: Contants.communityBackendURL)
    static var loginService = LoginService(accessMaterialRepository: accessMaterialRepository, loginBackend: loginBackend)
    
    static var baseURL = URL(string: AppWhitelabelConfig?["BACKEND_URL"] as! String)!
    static var backendURL = URL(string: AppWhitelabelConfig?["BACKEND_URL"] as! String)!
    static var alternativeURL = URL(string: AppWhitelabelConfig?["ALTERNATIVE_URL"] as! String)!
    static let chatRegion = AppWhitelabelConfig?["CHAT_REGION"] as! String
    static let chatSearchTitle = AppWhitelabelConfig?["CHAT_SEARCH_TITLE"] as! String
    static let chatTabBarTitle = AppWhitelabelConfig?["CHAT_TAB_BAR_TITLE"] as! String
    static let feedKey = AppWhitelabelConfig?["FEED_KEY"] as! String
    static let feedAppID = AppWhitelabelConfig?["FEED_APP_ID"] as! String
    static let feedSlug = AppWhitelabelConfig?["FEED_SLUG"] as! String
    static let globalLine = AppWhitelabelConfig?["GLOBAL_LINE"] as! String
    static let globalLogo = AppWhitelabelConfig?["GLOBAL_LOGO"] as! String
    static let globalWhitelabelCustomer = AppWhitelabelConfig?["GLOBAL_WHITELABEL_CUSTOMER"] as! String
    static let globalLogoLeftOffset = AppWhitelabelConfig?["GLOBAL_LOGO_LEFT_OFFSET"] as! Int
    static let globalLogoRightOffset = AppWhitelabelConfig?["GLOBAL_LOGO_RIGHT_OFFSET"] as! Int
    static let globalWhitelabelColor = AppWhitelabelConfig?["GLOBAL_WHITELABEL_COLOR"] as! String
    static let globalBackgroundColor = AppWhitelabelConfig?["GLOBAL_BACKGROUND_COLOR"] as! String
    static let globalBarButtonBackgroundColor = AppWhitelabelConfig?["GLOBAL_BAR_BUTTON_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonBackgroundColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonNormalStateBackgroundColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_NORMAL_STATE_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonSelectedStateBackgroundColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_SELECTED_STATE_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonHighlightedStateBackgroundColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_HIGHLIGHTED_STATE_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonDisabledStateBackgroundColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_DISABLED_STATE_BACKGROUND_COLOR"] as! String
    static let globalSolidButtonTitleColor = AppWhitelabelConfig?["GLOBAL_SOLID_BUTTON_TITLE_COLOR"] as! String
    static let globalTransparentButtonBorderColor = AppWhitelabelConfig?["GLOBAL_TRANSPARENT_BUTTON_BORDER_COLOR"] as! String
    static let globalTransparentButtonTitleColor = AppWhitelabelConfig?["GLOBAL_TRANSPARENT_BUTTON_TITLE_COLOR"] as! String
    static let globalTransparentButtonHighlightedColor = AppWhitelabelConfig?["GLOBAL_TRANSPARENT_BUTTON_HIGHLIGHTED_COLOR"] as! String
    static let globalLineSeparatorBackgroundColorWhiteAmount = AppWhitelabelConfig?["GLOBAL_LINE_SEPARATOR_BACKGROUND_COLOR_WHITE_AMOUNT"] as! Float
    static let globalNavigationBarTintColor = AppWhitelabelConfig?["GLOBAL_NAVIGATION_BAR_TINT_COLOR"] as! String
    static let globalNavigationBarTextAttributeColor = AppWhitelabelConfig?["GLOBAL_NAVIGATION_BAR_TEXT_ATTRIBUTE_COLOR"] as! String
    static let globalNavigationBarBackButtonTintColor = AppWhitelabelConfig?["GLOBAL_NAVIGATION_BAR_BACK_BUTTON_TINT_COLOR"] as! String
    static let globalTabBarIsTranslucent = AppWhitelabelConfig?["GLOBAL_TAB_BAR_IS_TRANSLUCENT"] as! Bool
    static let globalTabBarTintColor = AppWhitelabelConfig?["GLOBAL_TAB_BAR_TINT_COLOR"] as! String
    static let globalTabBarUnselectedItemTintColor = AppWhitelabelConfig?["GLOBAL_TAB_BAR_UNSELECTED_ITEM_TINT_COLOR"] as! String
    static let learnTabBarIcon = AppWhitelabelConfig?["LEARN_TAB_BAR_ICON"] as! String
    static let learnTabBarIconSelected = AppWhitelabelConfig?["LEARN_TAB_BAR_ICON_SELECTED"] as! String
    static let applicationApprovedText = AppWhitelabelConfig?["APPLICATION_APPROVED_TEXT"] as! String
    static let applicationApprovedButtonText = AppWhitelabelConfig?["APPLICATION_APPROVED_BUTTON_TEXT"] as! String
    static let applicationRejectionScreenTitle = AppWhitelabelConfig?["APPLICATION_REJECTION_SCREEN_TITLE"] as! String
    static let applicationSubmitText = AppWhitelabelConfig?["APPLICATION_SUBMIT_TEXT"] as! String
    static let applicationListTitle = AppWhitelabelConfig?["APPLICATION_LIST_TITLE"] as! String
    static let requestLoginScreenTextColor = AppWhitelabelConfig?["REQUEST_LOGIN_SCREEN_TEXT_COLOR"] as! String
    static let requestLoginScreenForegroundColor = AppWhitelabelConfig?["REQUEST_LOGIN_SCREEN_FOREGROUND_COLOR"] as! String
    static let storyboardWalletLanding = AppWhitelabelConfig?["STORYBOARD_WALLET_LANDING"] as! String
    static let storyboardLearnScreen = AppWhitelabelConfig?["STORYBOARD_LEARN_SCREEN"] as! String
    static let walletBalanceView1CurrencyName = AppWhitelabelConfig?["WALLET_BALANCE_VIEW1_CURRENCY_NAME"] as! String
    static let walletBalanceView1CurrencySymbol = AppWhitelabelConfig?["WALLET_BALANCE_VIEW1_CURRENCY_SYMBOL"] as! String
    static let walletBalanceView1CurrencyIcon = AppWhitelabelConfig?["WALLET_BALANCE_VIEW1_CURRENCY_ICON"] as! String
    static let walletBalanceView2CurrencyName = AppWhitelabelConfig?["WALLET_BALANCE_VIEW2_CURRENCY_NAME"] as! String
    static let walletBalanceView2CurrencySymbol = AppWhitelabelConfig?["WALLET_BALANCE_VIEW2_CURRENCY_SYMBOL"] as! String
    static let walletBalanceView2CurrencyIcon = AppWhitelabelConfig?["WALLET_BALANCE_VIEW2_CURRENCY_ICON"] as! String
    static let marketplaceCreateScreenPhotoIcon = AppWhitelabelConfig?["MARKETPLACE_CREATE_SCREEN_PHOTO_ICON"] as! String
    static let signupScreenCameraIcon = AppWhitelabelConfig?["SIGN_UP_SCREEN_CAMERA_ICON"] as! String
    static let signupScreenTextColor = AppWhitelabelConfig?["SIGN_UP_SCREEN_TEXT_COLOR"] as! String
    static let signupScreenForegroundColor = AppWhitelabelConfig?["SIGN_UP_SCREEN_FOREGROUND_COLOR"] as! String
    static var iPhone5Height = CGFloat(1136.0)
    
    static var communityBackendURL = baseURL.appendingPathComponent("/community")
    static var wishlistBackendURL = baseURL.appendingPathComponent("/wishlist")
    static var inventoryBackendURL = baseURL.appendingPathComponent("/inventory")
    static var inventoryBackupBackendURL = baseURL.appendingPathComponent("/inventory-backup")
    static var marketplaceBackendURL = baseURL.appendingPathComponent("/marketplace")
    static var communityChatTokenURL = baseURL.appendingPathComponent("/chat/new-token")
    static var communityFeedTokenURL = baseURL.appendingPathComponent("/feed/new-token")
    
    // TODO: Change to right one
    static let walletInfuraAccessToken = "10f2b086c927414fb219734068bb01c1"
    static let walletNetworkId = NetworkId.mainnet
    
    static var communityMemberChatLoggedIn: Bool = false
    static var communityMemberFeedLoggedIn: Bool = false
    
}
