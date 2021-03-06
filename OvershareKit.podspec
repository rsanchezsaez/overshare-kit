Pod::Spec.new do |s|
  s.name         = "OvershareKit"
  s.version      = "1.3.3-oe"
  s.summary      = "A soup-to-nuts sharing library for iOS."
  s.homepage     = "https://github.com/overshare/overshare-kit"
  s.license      = { :type => 'MIT', :file => 'LICENSE'  }
  s.author       = { "Jared Sinclair" => "desk@jaredsinclair.com", "Justin Williams" => "justin@carpeaqua.com" }
  s.source       = { :git => "https://github.com/obviousengineering/overshare-kit.git", :tag => "#{s.version}" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.frameworks   = 'UIKit', 'AddressBook', 'CoreMotion', 'CoreLocation'
  
  s.compiler_flags = "-fmodules"
  
  s.ios.deployment_target = '7.0'
  
  s.source_files = ['OvershareKit/*.{h,m}']
  s.resources    = ['OvershareKit/Images/*', 'OvershareKit/*.xib', 'Dependencies/GooglePlus-SDK/GooglePlus.bundle']

  s.ios.vendored_frameworks = 'Dependencies/GooglePlus-SDK/GooglePlus.framework', 'Dependencies/GooglePlus-SDK/GoogleOpenSource.framework'
  
  s.dependency 'ADNLogin'
  s.dependency 'AnimatedGIFImageSerialization'
  s.dependency 'Facebook-iOS-SDK'
  s.dependency 'PocketAPI'
  s.dependency 'TMTumblrSDK', '~> 1.0.10-oe'
end
