Pod::Spec.new do |s|
  s.name = "FDDataClient"
  s.version = "1.0.1"
  s.summary = "Networking and model layer to simplify the conversion from JSON to Objective-C."
  s.license = { :type => "MIT", :file => "LICENSE.md" }

  s.homepage = "https://github.com/reidmain/FDDataClient"
  s.author = "Reid Main"
  s.social_media_url = "http://twitter.com/reidmain"

  s.ios.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.source = { :git => "https://github.com/reidmain/FDDataClient.git", :tag => s.version }
  s.source_files = "FDDataClient/**/*.{h,m}"
  #s.private_header_files = "FDDataClient/**/*+Private.h"
  s.framework = "Foundation"
  s.requires_arc = true
  s.dependency "FDModel", "~> 2.0"
  s.dependency "FDRequestClient", "~> 1.0"
end
