source 'https://github.com/CocoaPods/Specs'

platform :ios, '7.0'

# Add Application pods here
pod 'AFNetworking'

pod 'CocoaSoundCloudAPI'
pod 'CocoaSoundCloudUI'

pod 'ReactiveCocoa'
pod 'GCDWebServer/WebUploader'
pod 'OrigamiEngine/Flac'
pod 'OrigamiEngine/Opus'
pod 'DZNEmptyDataSet'

pod 'FontAwesomeKit', '~> 2.1.0'

pod 'ChameleonFramework'

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

