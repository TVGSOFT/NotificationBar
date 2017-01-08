Pod::Spec.new do |s|
 
  s.platform              = :ios
  s.ios.deployment_target = '8.0'
  s.name                  = "NotificationBar"
  s.summary               = "Notification UI with alert and banner style. User can reply a message inside notification."
  s.requires_arc          = true
  s.version               = "0.0.1"
  s.license               = { :type => "MIT", :file => "LICENSE" }
  s.author                = { "TVG" => "tvg@gmail.com" }
  s.homepage              = "https://github.com/TVGSoft/NotificationBar"
  s.source                = { :git => "https://github.com/TVGSoft/NotificationBar.git", :tag => "#{s.version}"} 
  s.source_files          = "NotificationBar/Classes/**/*"
  s.resource_bundles      = {				
     	'NotificationBar' => ['NotificationBar/Classes/*.xib']
  }
  s.frameworks 			  = 'UIKit'

end