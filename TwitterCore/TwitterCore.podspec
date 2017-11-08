Pod::Spec.new do |s|
  s.name = "TwitterCore"
  s.version = "3.0.2"
  s.summary = "Increase user engagement and app growth."
  s.homepage = "https://dev.twitter.com/twitterkit/overview"
  s.documentation_url = "https://dev.twitter.com/twitterkit/ios/installation"
  s.social_media_url = "https://twitter.com/TwitterDev"
  s.authors = "Twitter"
  s.platforms = { :ios => "9.0", :tvos => "9.0" }
  s.source = { :http => "https://ton.twimg.com/syndication/twitterkit/ios/#{s.version}/TwitterCore.zip" }
  s.license = { :type => "Commercial", :text => "Copyright Twitter, Inc. All Rights Reserved. Use of this software is subject to the terms and conditions of the Twitter Kit Agreement located at https://dev.twitter.com/overview/terms/twitterkit and the Developer Agreement located at https://dev.twitter.com/overview/terms/agreement. OSS: https://dev.twitter.com/twitterkit/open-source-licenses" }
  s.ios.vendored_frameworks = "iOS/TwitterCore.framework"
  s.tvos.vendored_frameworks = "tvOS/TwitterCore.framework"
  s.ios.frameworks = "Accounts", "CoreData", "CoreGraphics", "Foundation", "Security", "Social", "UIKit"
  s.tvos.frameworks = "CoreData", "CoreGraphics", "Foundation", "Security", "UIKit"
end
