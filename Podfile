# Uncomment this line to define a global platform for your project
platform :ios, '9.2'

target 'HomeworkManager' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'RealmSwift', '~> 0.102.1'

  # Pods for HomeworkManager

  target 'HomeworkManagerTests' do
    inherit! :search_paths
    pod 'RealmSwift', '~> 0.102.1'
    # Pods for testing
  end

  target 'HomeworkManagerUITests' do
    inherit! :search_paths
    pod 'RealmSwift', '~> 0.102.1'
    # Pods for testing
  end
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '2.3'
      end
    end
  end
  
end

