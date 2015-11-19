source 'https://github.com/CocoaPods/Specs'

platform :ios, '7.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# Add Application pods here

# Networking
pod 'AFNetworking'
pod 'CocoaSoundCloudAPI'
pod 'CocoaSoundCloudUI'
pod 'GCDWebServer/WebUploader'

# Sound
pod 'OrigamiEngine', :git => 'https://github.com/darkcl/OrigamiEngine.git'
pod 'OrigamiEngine/Flac', :git => 'https://github.com/darkcl/OrigamiEngine.git'
pod 'OrigamiEngine/Opus', :git => 'https://github.com/darkcl/OrigamiEngine.git'

# UI
pod 'DZNEmptyDataSet'
pod 'FontAwesomeKit', '~> 2.1.0'
pod 'ChameleonFramework'
pod 'FLKAutoLayout'

# Database
pod 'YapDatabase'
pod 'Mantle'

# General
pod 'ReactiveCocoa'

target :unit_tests, :exclusive => true do
  link_with 'UnitTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end


# Copy acknowledgements to the Settings.bundle

post_install do | installer |
  require 'fileutils'

  pods_acknowledgements_path = 'Pods/Target Support Files/Pods/Pods-Acknowledgements.plist'
  settings_bundle_path = Dir.glob("**/*Settings.bundle*").first

  if File.file?(pods_acknowledgements_path)
    puts 'Copying acknowledgements to Settings.bundle'
    FileUtils.cp_r(pods_acknowledgements_path, "#{settings_bundle_path}/Acknowledgements.plist", :remove_destination => true)
  end
end

