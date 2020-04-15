//
//  Root.swift
//  s33d
//
//  Created by Andrii Selivanov on 2/15/19.
//  Copyright © 2019 214Alpha. All rights reserved.
//

import Foundation
import UIKit
import CommunityKit
import WishKit
import FlowKit
import RealmSwift
import InventoryKit
import WalletKit
import KeychainAccess
import XLPagerTabStrip

class Root {
    
    let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window

        Contants.applicationRoot = ApplicationRoot(loginService: Contants.loginService, loggedOutFlow: buildLoggedOutFlow(loginService: Contants.loginService), loggedInFlowFactory: buildLoggedInFlowFactory(keychain: Contants.keychain), window: window)
        
    }
    
    func buildLoggedOutFlow(loginService: LoginServiceProtocol) -> LoggedOutFlowProtocol {
        return LoggedOutFlowFactory.build(
            navigationController: DefaultNavigationController(),
            landingPagePresenter: LandingPagePresenter(view: LandingPageScreen()),
            requestLoginPresenter: RequestLoginPresenter(view: RequestLoginScreen(), loginService: loginService),
            loginPresenterFactory: { emailAddress in LoginPresenter(view: LoginVerificationCodeScreen(), loginService: loginService, emailAddress: emailAddress) },
            signUpPresenter: SignUpPresenter(view: SignUpScreen(), loginService: loginService))
    }
    
    func buildLoggedInFlowFactory(keychain: Keychain) -> (_ accessMaterial: AccessMaterial) -> LoggedInFlow {
        return { (accessMaterial: AccessMaterial) -> LoggedInFlow in
            let database = try! CommunityKitDatabaseFactory.buildDatabase(accessMaterial: accessMaterial)
            let memberRepository =  MemberRepository(db: database)
            let memberService = MemberService(
                accessMaterial: accessMaterial,
                memberBackend: MemberBackend(
                    url: Contants.communityBackendURL,
                    accessMaterial: accessMaterial
                ),
                memberRepository: memberRepository
            )
            
            return LoggedInFlow(
                memberService: memberService,
                loadingFlow: LoadingFlow(),
                mainApplicationFlowFactory: self.buildMainApplicationFlowFactory(
                    accessMaterial: accessMaterial,
                    database: database,
                    memberService: memberService,
                    memberRepository: memberRepository,
                    keychain: keychain))
        }
    }
    
    func buildMainApplicationFlowFactory(
        accessMaterial: AccessMaterial,
        database: Realm,
        memberService: MemberServiceProtocol,
        memberRepository: MemberRepositoryProtocol,
        keychain: Keychain) -> (_ member: Member) -> Flow {
        return { (member: Member) -> Flow in
            let memberVerificationBackend = MemberVerificationBackend(url: Contants.communityBackendURL, accessMaterial: accessMaterial)
            let memberVerificationApplicationRepository = MemberVerificationApplicationRepository(db: database)
            let memberVerificationService = MemberVerificationService(
                accessMaterial: accessMaterial,
                memberVerificationBackend: memberVerificationBackend,
                memberVerificationApplicationRepository: memberVerificationApplicationRepository)
            
            let memberVerificationFlow = self.buildMemberVerificationFlow(
                accessMaterial: accessMaterial,
                memberVerificationService: memberVerificationService,
                memberService: memberService)
            
            let applicationsReviewFlow = self.buildApplicationsReviewFlow(
                accessMaterial: accessMaterial,
                memberRepository: memberRepository,
                memberVerificationApplicationRepository: memberVerificationApplicationRepository,
                memberService: memberService)
            
            let viewMemberFlow = self.buildViewMemberFlow(memberService: memberService)
            
            // TODO: Get learn flow back
            let learnFlow = self.buildLearnFlow()
            let chatFlow = self.buildChatFlow()
            let walletFlow = self.buildWalletFlow(keychain: keychain, memberService: memberService)
            let homeFlow = self.buildHomeFlow(accessMaterial: accessMaterial, memberService: memberService)
            let profileFlow = self.buildProfileFlow(isAdmin:(try? memberService.getCurrentMember())??.isAdmin == .some(true),viewMemberFlow: viewMemberFlow, applicationsReviewFlow: applicationsReviewFlow)
        
            let applicationsReviewTabBarItem = TabBarItem(flow: applicationsReviewFlow, shouldBeShown: {
                return (try? memberService.getCurrentMember())??.isAdmin == .some(true)
            })
            
            let memberVerificationTabBarItem = TabBarItem(flow: memberVerificationFlow, shouldBeShown: { () -> Bool in
                // Show flow if there is no approved application yet
                switch (try? memberVerificationService.getCurrentApplication())??.state {
                case .some(.approved):
                    return false
                default:
                    return true
                }
            })
            
            let profileTabBarItem = TabBarItem(flow: profileFlow, shouldBeShown: { () -> Bool in
                return true
            })
            
            let learnTabBarItem = TabBarItem(flow: learnFlow, shouldBeShown: { () -> Bool in
                let member = try? memberService.getCurrentMember()
                
                // Show learn screen for admins too
                if member??.isAdmin == .some(true) {
                    return true
                }
                
                switch (try? memberVerificationService.getCurrentApplication())??.state {
                case .some(.approved):
                    return true
                default:
                    return false
                }
            })
            
            let chatTabBarItem = TabBarItem(flow: chatFlow, shouldBeShown: { () -> Bool in
                let member = try? memberService.getCurrentMember()
                
                let memberIDString = member??.id.id ?? ""
                
                if memberIDString == "" {
                    return false
                }
                
                // Always show for admins
                if member??.isAdmin == .some(true) {
                    if Contants.communityMemberChatLoggedIn == false {
                        ChatLogin(memberID : memberIDString, rawAccessToken : accessMaterial.accessToken.rawAccessToken, URLString: Contants.communityChatTokenURL.absoluteString)
                    }
                    if Contants.communityMemberFeedLoggedIn == false {
                        FeedLogin(memberID : memberIDString, rawAccessToken : accessMaterial.accessToken.rawAccessToken, URLString: Contants.communityFeedTokenURL.absoluteString)
                    }
                    return true
                }
                
                switch (try? memberVerificationService.getCurrentApplication())??.state {
                    
                case .some(.approved):
                    if Contants.communityMemberChatLoggedIn == false {
                        ChatLogin(memberID : memberIDString, rawAccessToken : accessMaterial.accessToken.rawAccessToken, URLString: Contants.communityChatTokenURL.absoluteString)
                    }
                    if Contants.communityMemberFeedLoggedIn == false {
                        FeedLogin(memberID : memberIDString, rawAccessToken : accessMaterial.accessToken.rawAccessToken, URLString: Contants.communityFeedTokenURL.absoluteString)
                    }
                    return true
                default:
                    return false
                }
                
            })
            
            
            let walletTabBarItem = TabBarItem(flow: walletFlow, shouldBeShown: { () -> Bool in
                return true
            })
            
            let homeTabBarItem = TabBarItem(flow: homeFlow, shouldBeShown: { () -> Bool in
                let member = try? memberService.getCurrentMember()
                
                // Always show home screen for admins
                if member??.isAdmin == .some(true) {
                    return true
                }
                
                switch (try? memberVerificationService.getCurrentApplication())??.state {
                case .some(.approved):
                    return true
                default:
                    return false
                }
            })
            
            var tabBarItems = [TabBarItem]()
            switch member.isAdmin {
            case true:
                switch Contants.globalWhitelabelCustomer {
                case "s33d":
                    tabBarItems = [chatTabBarItem, learnTabBarItem, homeTabBarItem, walletTabBarItem, profileTabBarItem]
                default:
                    tabBarItems = [chatTabBarItem, walletTabBarItem, profileTabBarItem]
                }
                
            case false:
                switch Contants.globalWhitelabelCustomer {
                case "s33d":
                    tabBarItems = [chatTabBarItem, learnTabBarItem, homeTabBarItem, walletTabBarItem, memberVerificationTabBarItem,  profileTabBarItem]
                default:
                   tabBarItems = [learnTabBarItem, chatTabBarItem,  walletTabBarItem, memberVerificationTabBarItem, profileTabBarItem]
                }
            }
            
            let tabBarControler = DefaultTabBarController()
            tabBarControler.selectedIndex = 1
            let builder = FlowBuilder(rootFlow: TabBarNavigationFlow(tabBarController: tabBarControler, tabBarItems: tabBarItems))
           
            builder.on(MemberVerificationCompletedAction.self) { flow, _ in
                flow.updateSubflowsDisplaying()
            }
            return builder.rootFlow
        }
    }
    
    func buildChatFlow() -> Flow {
        let flow = ChatFlow()
        flow.prepareToStart()
        flow.rootViewController().tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "chat_tab_bar_icon"), selectedImage: UIImage(named: "chat_tab_bar_icon"))
        
        return flow
    }

    
    func buildHomeFlow(accessMaterial: AccessMaterial, memberService: MemberServiceProtocol) -> HomeFlow {
        let yOurStoryFlow = self.buildYourStoryFlow()
        let wishListFlow = self.buildWishListFlow(accessToken: accessMaterial.accessToken)
        let inventoryFlow = self.buildInventoryFlow(accessToken: accessMaterial.accessToken, memberService: memberService)
        let flow = HomeFlow(pagerItems: [inventoryFlow, wishListFlow, yOurStoryFlow].map { PagerItem(flow: $0) } )
        flow.pagerController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "home_tab_bar_icon"), selectedImage: UIImage(named: "home_tab_bar_icon_selected"))
        
        return flow
    }
    
    func buildProfileFlow(isAdmin: Bool, viewMemberFlow: Flow, applicationsReviewFlow : Flow) -> ProfileFlow {
        
        var flow = ProfileFlow(profileItems: [viewMemberFlow].map { PagerItem(flow: $0) } )
        flow.pagerController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profile_tab_icon"), selectedImage: nil)
        
        if isAdmin {
            flow = ProfileFlow(profileItems: [viewMemberFlow, applicationsReviewFlow].map { PagerItem(flow: $0) } )
            flow.pagerController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "profile_tab_icon"), selectedImage: nil)
        }
       
        
        return flow
    }
    
    func buildMemberVerificationFlow(accessMaterial: AccessMaterial, memberVerificationService: MemberVerificationService, memberService: MemberServiceProtocol) -> MemberVerificationFlowProtocol {
        let navigationController = DefaultNavigationController()
        navigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "application_tab_icon"), selectedImage: nil)
        
        let memberVerificationFlow = MemberVerificationFlowFactory.build(
            navigationController: navigationController,
            sendMemberVerificationFlow: SendMemberVerificationFlow(
                presenter: SendMemberVerificationPresenter(
                    view: SendMemberVerificationApplicationScreen(),
                    memberVerificationService: memberVerificationService)),
            memberVerificationStatusFlowFactory: { application -> MemberVerificationStatusFlowProtocol in
                return MemberVerificationStatusFlow(
                    presenter: MemberVerificationStatusPresenter(
                        view: MemberVerificationApplicationStatusScreen(),
                        application: application,
                        memberVerificationService: memberVerificationService))
        },
            memberVerificationService: memberVerificationService)
        
        return memberVerificationFlow
    }
    
    func buildApplicationsReviewFlow(
        accessMaterial: AccessMaterial,
        memberRepository: MemberRepositoryProtocol,
        memberVerificationApplicationRepository: MemberVerificationApplicationRepositoryProtocol,
        memberService: MemberServiceProtocol) -> ApplicationsReviewFlowProtocol {
        let navigationController = DefaultNavigationController()
        navigationController.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "administration_tab_icon"), selectedImage: nil)
        
        let applicationsReviewBackend = ApplicationsReviewBackend(url: Contants.communityBackendURL, accessMaterial: accessMaterial)
        let applicationsReviewService = ApplicationsReviewService(
            accessMaterial: accessMaterial,
            applicationsReviewBackend: applicationsReviewBackend,
            memberRepository: memberRepository,
            memberVerificationApplicationRepository: memberVerificationApplicationRepository)
        
        let applicationsReviewFlow = ApplicationsReviewFlowFactory.build(
            navigationController: navigationController,
            applicationListPresenter: ApplicationsListPresenter(
                view: ApplicationsListScreen(),
                applicationsReviewService:
                applicationsReviewService,
                memberService: memberService),
            applicationDetailsPresenterFactory: { application in
                return ApplicationDetailsPresenter(
                    view: ApplicationDetailsScreen(),
                    memberVerificationApplication: application,
                    applicationsReviewService: applicationsReviewService,
                    memberService: memberService)
        })
        
        return applicationsReviewFlow
    }
    
    func buildViewMemberFlow(memberService: MemberServiceProtocol) -> Flow {
        let viewMemberScreen = ViewMemberScreen()
        
        let viewMemberFlow = ViewMemberFlow(presenter: ViewCurrentMemberPresenter(view: viewMemberScreen, memberService: memberService))
        
        return viewMemberFlow
    }
    
    func buildMeditationFlow(memberVerificationService: MemberVerificationServiceProtocol) -> MeditationFlow {
        let meditationFlow = MeditationFlow(memberVerificationService: memberVerificationService)
        meditationFlow.rootViewController().tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "meditation_tab_icon"), selectedImage: nil)
        
        return meditationFlow
    }
    
    func buildWishListFlow(accessToken: AccessToken) -> WishListFlowProtocol {
        let database = try! WishKitDatabaseFactory.buildDatabase(subjectId: accessToken.subject.id)
        
        let wishService = WishService(wishBackend: WishBackend(url: Contants.wishlistBackendURL, rawAccessToken: accessToken.rawAccessToken), wishRepository: WishRepository(db: database))
        
        let wishListFlow = WishListFlowFactory.build(
            navigationController: DefaultNavigationController(),
            wishListPresenter: WishListPresenter(view: WishListScreen(), wishService: wishService),
            wishDetailsFlowFactory: { wish in
                return WishDetailsFlowFactory.build(
                    wishDetailsPresenterFactory: { wish in
                        return WishDetailsPresenter(view: WishDetailsScreen(), wish: wish, wishService: wishService)
                }, wish: wish)
        },
            wishCreateFlow: WishCreateFlowFactory.build(
                wishCreatePresenter: WishCreatePresenter(
                    view: WishCreateScreen(),
                    wishService: wishService)
            )
        )
        
        return wishListFlow
    }
    
    func buildInventoryFlow(accessToken: AccessToken, memberService: MemberServiceProtocol) -> InventoryListFlowProtocol {
        let database = try! InventoryKitDatabaseFactory.buildDatabase(subjectId: accessToken.subject.id)
        
        let inventoryService = InventoryService(
            inventoryBackend: InventoryBackend(
                url: Contants.inventoryBackendURL,
                rawAccessToken: accessToken.rawAccessToken),
            inventoryRepository: InventoryItemRepository(db: database))
        
        let inventoryListFlow = InventoryListFlowFactory.build(
            navigationController: DefaultNavigationController(),
            inventoryListPresenter: InventoryListPresenter(
                view: InventoryListScreen(),
                inventoryService: inventoryService,
                memberService: memberService),
            inventoryItemDetailsFlowFactory: { item in
                return InventoryItemDetailsFlowFactory.build(
                    inventoryItemDetailsPresenterFactory: { item in
                        return InventoryItemDetailsPresenter(
                            view: InventoryItemDetailsScreen(),
                            inventoryItem: item,
                            inventoryService: inventoryService, memberService: memberService)
                }, item: item,
                   inventoryItemEditFlowFactory: { item in
                    return InventoryItemEditFlowFactory.build(
                        inventoryItemEditPresenterFactory: { item in
                            return InventoryItemEditPresenter(view: InventoryItemEditScreen(), inventoryService: inventoryService, inventoryItem: item)
                    },
                        item: item)
                })
        },
            inventoryItemCreateFlow: InventoryItemCreateFlowFactory.build(
                inventoryItemCreatePresenter: InventoryItemCreatePresenter(
                    view: InventoryItemCreateScreen(),
                    inventoryService: inventoryService)
            )
        )
        
        return inventoryListFlow
    }
    
    func buildWalletFlow(keychain: Keychain, memberService: MemberServiceProtocol) -> WalletFlowProtocol {
        let walletRepository = WalletRepository(keychain: keychain, networkID: Contants.walletNetworkId, infuraAccessToken: Contants.walletInfuraAccessToken, memberService: memberService)
        
        let flow = WalletFlowFactory.build(
            addWalletFlow: buildAddWalletFlow(),
            walletOverviewFlowFactory: { wallet -> WalletOverviewFlowProtocol in
                return self.buildWalletOverviewFlow(wallet: wallet)
        },
            walletRepository: walletRepository)
        
        flow.rootViewController().tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "wallet_tab_bar_icon"), selectedImage: UIImage(named: "wallet_tab_bar_icon_selected"))
        
        return flow
    }
    
    func buildWalletOverviewFlow(wallet: Wallet) -> WalletOverviewFlowProtocol {
        let ethereumPriceService = EthereumPriceService()
        
        return WalletOverviewFlowFactory.build(
            walletOverviewPresenter: WalletOverviewPresenter(
                view: WalletOverviewScreen(),
                wallet: wallet,
                ethereumPriceService: ethereumPriceService),
            sendEtherFlowFactory: { wallet -> SendEtherFlowProtocol in
                return SendEtherFlowFactory.build(
                    sendEtherPresenter: SendEtherPresenter(
                        view: SendEtherScreen(),
                        wallet: wallet,
                        ethereumPriceService: ethereumPriceService)
                )
        }, receiveEtherFlowFactory: { wallet -> ReceiveEtherFlowProtocol in
            return ReceiveEtherFlowFactory.build(
                receiveEtherPresenter: ReceiveEtherPresenter(
                    view: ReceiveEtherScreen(),
                    wallet: wallet)
            )
        })
    }
    
    func buildAddWalletFlow() -> AddWalletFlowProtocol {
        let addWalletFlow = AddWalletFlowFactory.build(
            navigationController: DefaultNavigationController(),
            walletLandingPresenter: WalletLandingPresenter(
                view: UIStoryboard(name: Contants.storyboardWalletLanding, bundle: nil).instantiateInitialViewController() as! WalletLandingScreen),
            createMnemonicFlowFactory: {
                return CreateMnemonicFlowFactory.build(
                    // TODO: Fix try! call
                    createMnemonicPresenter: CreateMnemonicPresenter(view: CreateMnemonicScreen(), wallet: try! Wallet.factory(network: Contants.walletNetworkId, infuraAccessToken: Contants.walletInfuraAccessToken))
                )
        },
            confirmMnemonicFlowFactory: { wallet in
                return ConfirmMnemonicFlowFactory.build(
                    confirmMnemonicPresenter: ConfirmMnemonicPresenter(view: EnterMnemonicScreen(), wallet: wallet)
                )
        },
            restoreMnemonicFlowFactory: {
                return RestoreMnemonicFlowFactory.build(
                    restoreMnemonicPresenter: RestoreMnemonicPresenter(view: EnterMnemonicScreen(), walletFactory: { mnemonic in
                        return try Wallet(mnemonic: mnemonic, network: Contants.walletNetworkId, infuraAccessToken: Contants.walletInfuraAccessToken)
                    })
                )
        }
        )
        
        return addWalletFlow
    }
    
    func buildLearnFlow() -> Flow {
        let presenter = UIStoryboard(name: Contants.storyboardLearnScreen, bundle: nil).instantiateInitialViewController() as! LearnScreen
        presenter.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: Contants.learnTabBarIcon), selectedImage: UIImage(named: Contants.learnTabBarIconSelected))
        
        return SingleScreenFlow(presenter: presenter)
    }
    
    func buildYourStoryFlow() -> Flow {
    
        return SingleScreenFlow(presenter: FeedPlaceholderScreen())
    }
    
    func runApplication() {
       Contants.applicationRoot.boot()
    }
    
}
