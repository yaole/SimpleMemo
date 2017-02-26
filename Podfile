

platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'SimpleMemo' do
	
	pod 'EvernoteSDK',  :git => 'https://github.com/evernote/evernote-cloud-sdk-ios.git'
  pod 'SnapKit', '~> 3.2.0'
	
	target 'SimpleMemoTests' do
		inherit! :search_paths
	end
end

post_install do | installer |
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['SWIFT_VERSION'] = '3.0'
		end
	end
end
