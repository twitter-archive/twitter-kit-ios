#
# Be sure to run `pod lib lint Punycode-Cocoa.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Punycode-Cocoa"
  s.version          = "1.2.2"
  s.summary          = "Punycode/IDNA category on NSString, based on RFC 3492, RFC 3490."
  s.description      = <<-DESC
  A simple punycode/IDNA category on NSString, based on code and documentation from RFC 3492 and RFC 3490. Use this to convert internationalized domain names (IDN) between Unicode and ASCII.
  
  déjà.vu.example → xn--dj-kia8a.vu.example
   
                       DESC
  s.homepage         = "https://github.com/Wevah/Punycode-Cocoa"
  s.license          = 'BSD'
  s.authors          = { "Nate Weaver (Wevah)" => "wevah [snail] derailer [splot] org" }
  s.source           = { :git => "https://github.com/Wevah/Punycode-Cocoa.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = 'Pod/**/*'
end
