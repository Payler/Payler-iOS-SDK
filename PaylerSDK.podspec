#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PaylerSDK"
  s.version          = "1.0"
  s.license          = 'MIT'
  s.summary          = "iOS SDK for Payler Gate API"
  s.author           = { "Maxim Pavlov" => "mp@poloniumarts.com" }
  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'PaylerSDK'
  s.public_header_files = 'PaylerSDK/*.h'

  s.dependency 'AFNetworking/NSURLConnection', '~> 2.3'
  s.dependency 'AFNetworking/Security', '~> 2.3'
  s.dependency 'AFNetworking/Serialization', '~> 2.3'
end
