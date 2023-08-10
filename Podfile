# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

use_frameworks!

inhibit_all_warnings!
target 'WebAuthn' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for WebAuthn
pod 'Alamofire'
pod "PromiseKit"
pod 'SwiftyJSON'

pod 'SnapKit'
pod 'HandyJSON'
pod 'IQKeyboardManagerSwift'
pod 'Kingfisher'
pod 'YYKit'
pod 'WebAuthnKit'
pod 'SwiftEventBus'
pod 'Reusable'
pod 'SVProgressHUD'
pod 'Toast-Swift'
end


post_install do |pi|
    pi.pods_project.targets.each do |t|
        t.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
        end
    end
end
