source 'https://github.com/CocoaPods/Specs'

platform :ios, '8.0'

# ignore all warnings from all pods
inhibit_all_warnings!

# Add Application pods here
target 'Wave Hub' do
    # Networking
    pod 'AFNetworking'
    pod 'CocoaSoundCloudAPI'
    pod 'CocoaSoundCloudUI'
    pod 'GCDWebServer/WebUploader'
    pod 'DLImageLoader'
    pod 'NPAudioStream', :git => 'https://github.com/darkcl/NPAudioStream.git'
    
    # Sound
    pod 'OrigamiEngine', :git => 'https://github.com/darkcl/OrigamiEngine.git'
    pod 'OrigamiEngine/Flac', :git => 'https://github.com/darkcl/OrigamiEngine.git'
    pod 'OrigamiEngine/Opus', :git => 'https://github.com/darkcl/OrigamiEngine.git'
    pod 'FreeStreamer'

    # UI
    pod 'DZNEmptyDataSet'
    pod 'FontAwesomeKit', '~> 2.1.0'
    pod 'ChameleonFramework'
    pod 'FLKAutoLayout'
    pod 'SVProgressHUD'
    pod 'MNTPullToReact', '~> 1.0'
    pod 'MJRefresh'
    pod 'YSLTransitionAnimator'
    pod 'RMPZoomTransitionAnimator'
    pod 'SCSiriWaveformView', :git => 'https://github.com/darkcl/SCSiriWaveformView.git'

    # Database
    pod 'YapDatabase'
    pod 'Mantle'

    # General
    pod 'ReactiveCocoa'
    pod 'Block-KVO', :git => 'https://github.com/Tricertops/Block-KVO.git'
    pod 'JRNLocalNotificationCenter'
    
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
  
  installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
          config.build_settings['ENABLE_BITCODE'] = 'NO'
      end
  end
end

