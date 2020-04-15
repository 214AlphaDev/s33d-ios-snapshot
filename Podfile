platform :ios, '12.0'

def shared_pods
  pod 'FlowKit', :git => 'git@github.com:214AlphaDev/flowkit.git', :commit => 'ca7887ddb6219aa9c010f8546a4fe256e4b6bbd3'
  pod 'CommunityKit', :git => 'git@github.com:214AlphaDev/communitykitios.git', :commit => '3a207f7eb01b96aef5630223e3b4dc6a1f9cd15f'
  pod 'WishKit', :git => 'git@github.com:214AlphaDev/wishkit.git', :commit => '21d9d687607a91c8c772f6f0e4f6c6e29aee58ae'
  pod 'InventoryKit', :git => 'git@github.com:214AlphaDev/inventory-kit-ios.git', :commit => '97844127b81091ba14586919efbd6262bb841f42'
  pod 'WalletKit', :git => 'git@github.com:214AlphaDev/wallet-kit.git', :commit => '5b965b2483f0e857bbb29adff4132750e34705fe'
  pod 'web3swift', :git => 'git@github.com:214AlphaDev/web3swift.git', :commit => 'af07105a1f1d0c1b361950a793eee9dd34d04568'
  pod 'SnapKit', '5.0'
  pod 'Fusuma', '1.3.3'
  pod 'NVActivityIndicatorView', '4.6.1'
  pod 'UITextView+Placeholder', '1.2.1'
  pod 'NewPopMenu', '2.1.2'
  pod 'XLPagerTabStrip', '8.1.1'

  pod 'CometChatPro', '~> 2.0.0-beta2'
  pod 'SDWebImage', '~> 4.0'
  pod 'XLActionController'
  pod 'YPImagePicker'
  pod 'CachingExtension','1.0.12-beta'

  pod 'GetStreamActivityFeed', '~> 2.0.0'
end

target 's33d' do
  use_frameworks!

  shared_pods

end

# Fix for PromiseKit uses Swift 5.0 version which is not yet supported by this project
post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['PromiseKit'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
      end
    end
  end
  
  plist_buddy = "/usr/libexec/PlistBuddy" 
  version = "2.0.0" 
  `#{plist_buddy} -c "Set CFBundleShortVersionString #{version}" "Pods/CometChatPro/CometChatPro.framework/Info.plist"`  
end
