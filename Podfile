# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'RetirePro' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for RetirePro
  pod 'Charts', '~> 3.0.1'
  pod 'RealmSwift', '~> 2.0.2'
  pod 'IQKeyboardManagerSwift'
  pod 'TextFieldEffects'
  pod 'SubmitButton'
  pod 'RMPickerViewController', '~> 2.2.1'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.0'
      end
    end
  end
end
