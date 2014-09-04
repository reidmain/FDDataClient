Pod::Spec.new do |s|

  s.name = "FDDataClient"
  s.version = "0.2.0"
  s.summary = "1414 Degrees' REST API to local models layer."
  s.license = { :type => "MIT", :file => "LICENSE.md" }

  s.homepage = "https://github.com/reidmain/FDDataClient"
  s.author = "Reid Main"
  s.social_media_url = "http://twitter.com/reidmain"

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source = { :git => "https://github.com/reidmain/FDDataClient.git", :tag => s.version }
  s.source_files = "FDDataClient/**/*.{h,m}"
  s.private_header_files = "FDDataClient/**/*+Private.h"
  s.framework = "Foundation"
  s.requires_arc = true
  s.dependency "FDRequestClient"
end
