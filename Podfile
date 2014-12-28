platform :ios, '7.0'
pod 'FontAwesomeKit', '~> 2.1.0'
pod 'UICKeyChainStore'
pod 'LKBadgeView', :git => 'https://github.com/lakesoft/LKBadgeView.git'
pod 'CMPopTipView'
pod 'NJKWebViewProgress'
pod 'HatenaBookmarkSDK'
pod 'Evernote-SDK-iOS'
pod 'CTFeedback'
pod 'MTMigration'
pod 'TSMessages'
pod 'JVFloatLabeledTextField'
pod 'NXOAuth2Client', '~> 1.2.6'
pod 'M2DWebViewController'
pod 'SVProgressHUD'
pod 'TUSafariActivity', '~> 1.0.1'
pod 'GLDTween', '~> 0.0.2'
pod 'UIDeviceUtil', '~> 1.0.2'

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'ryydr/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
