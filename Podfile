platform :ios, '7.0'
pod 'FontAwesomeKit', '~> 2.1.0'
pod 'SVProgressHUD', :head
pod 'UICKeyChainStore'
pod 'LKBadgeView', :git => 'https://github.com/lakesoft/LKBadgeView.git'
pod 'CMPopTipView'
pod 'NJKWebViewProgress'
pod 'HatenaBookmarkSDK'
pod 'Evernote-SDK-iOS'
pod 'CTFeedback'
pod 'MTMigration'
pod 'TSMessages'

post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Pods-acknowledgements.plist', 'ryydr/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end