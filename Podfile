platform :ios, "9.0"
use_frameworks!

target "Exsilio" do
  pod "Alamofire", "~> 4.0"
  pod "AlamofireImage", "~> 3.1.0"
  pod "AlamofireNetworkActivityIndicator", "~> 2.0"

  pod "FBSDKCoreKit"
  pod "FBSDKLoginKit"
  pod "FBSDKShareKit"
  pod "DZNEmptyDataSet"
  pod "Fusuma", git: "git@github.com:ytakzk/Fusuma.git"
  pod "SCLAlertView"
  pod "Mapbox-iOS-SDK", "~> 3.7"
  pod "FontAwesome.swift", git: "git@github.com:thii/FontAwesome.swift"
  pod "SwiftyJSON", "~> 3.1.1"
  pod "SWTableViewCell", "~> 0.3.7"
  pod "Eureka", "~> 4.1"
  pod "SkyFloatingLabelTextField", git: "https://github.com/MLSDev/SkyFloatingLabelTextField.git", branch: "swift3"
  pod "SVProgressHUD"
  pod "SwiftMessages", "~> 3.0.1"
  pod "TPKeyboardAvoiding"
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == "Eureka"
      target.build_configurations.each do |config|
        config.build_settings["SWIFT_VERSION"] = "4.0"
      end
    end
  end
end
