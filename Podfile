
platform :ios, '9.0'
#use_frameworks!


def prefs_pods
  pod 'SSZipArchive'
  pod 'DZNEmptyDataSet'
  pod 'Color-Picker-for-iOS'
  pod 'MXParallaxHeader'
  pod 'SDWebImage', '~> 4.0'
end

def tweak_pods
  pod 'LEColorPicker'
  pod 'SDWebImage', '~> 4.0'
end



target 'ColoredVK' do
  tweak_pods
end

target 'ColoredVK-NonJail' do
  prefs_pods
  tweak_pods
end

target 'ColoredVK-Prefs' do
  prefs_pods
end

target 'Prefs Application' do
  prefs_pods
end



post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.0'
      config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'NO'
      config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'NO'
      config.build_settings['CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS'] = 'NO'
      
      if target.name.include?("ColoredVK")
      	config.build_settings['CLANG_WARN_STRICT_PROTOTYPES'] = 'YES'
      	config.build_settings['CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF'] = 'YES'
      	config.build_settings['CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS'] = 'YES'
      end
    end
  end
end