

platform :ios, '10.0'
inhibit_all_warnings!
use_frameworks!

target 'SimpleMemo' do
	
	pod 'EvernoteSDK',  :git => 'https://github.com/evernote/evernote-cloud-sdk-ios.git'
  pod 'SnapKit', :git => 'https://github.com/SnapKit/SnapKit.git', :commit => 'ff97375b22fdf6a28a06e7f06823ce97b44c5037'
	
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
