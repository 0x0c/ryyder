platform :ios, '9.0'

target ‘ryyder’ do

pod 'FontAwesomeKit'
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
pod 'NXOAuth2Client'
pod 'M2DAPIGatekeeper'
pod 'M2DWebViewController', :git => 'git@github.com:0x0c/M2DWebViewController.git'
pod 'SVProgressHUD'
pod 'TUSafariActivity'
pod 'GLDTween'
pod 'UIDeviceUtil'

end

post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods-ryyder/Pods-ryyder-acknowledgements.plist', 'ryydr/Settings.bundle/Acknowledgements.plist', :remove_destination => true)
end
