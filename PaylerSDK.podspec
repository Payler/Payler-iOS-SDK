Pod::Spec.new do |s|
  s.name                = 'PaylerSDK'
  s.version             = '1.1'
  s.license             = 'MIT'
  s.homepage            = 'https://github.com/Payler/Payler-iOS-SDK'
  s.summary             = 'iOS SDK for Payler Gate API'

  s.author              = { 'Maxim Pavlov' => 'mp@poloniumarts.com' }
  s.social_media_url    = 'http://payler.com'

  s.platform            = :ios, '6.0'
  s.source              = { :git => 'https://github.com/Payler/Payler-iOS-SDK.git', :tag => s.version.to_s }
  s.source_files        = 'PaylerSDK/*.{h,m}'
  s.ios.resource_bundle = { 'PaylerSDK' => 'PaylerSDK/*.cer' }

  s.requires_arc = true
  s.dependency 'AFNetworking/NSURLConnection', '~> 2.3'
  s.dependency 'AFNetworking/Security', '~> 2.3'
  s.dependency 'AFNetworking/Serialization', '~> 2.3'
end
