Pod::Spec.new do |s|
  s.name         = "RCLighting"
  s.version 	 = "0.1"
  s.summary      = "Simple lighting (breathing light) effect."
  s.homepage     = "https://github.com/RidgeCorn/RCLighting"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors	 = { "Looping" => "www.looping@gmail.com" }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'

  s.source       = { :git => "https://github.com/RidgeCorn/RCLighting.git", :tag => s.version.to_s }
  s.source_files  = 'RCLighting'
  s.public_header_files = 'RCLighting/*.h'

  s.requires_arc = true

  s.dependency 'pop'
end
