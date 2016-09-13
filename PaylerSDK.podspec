Pod::Spec.new do |s|
  s.name                = 'PaylerSDK'
  s.version             = '2.1.1'
  s.license             = 'MIT'
  s.homepage            = 'https://github.com/Payler/Payler-iOS-SDK'
  s.summary             = 'iOS SDK for Payler Gate API'

  s.author              = { 'Maxim Pavlov' => 'mp@poloniumarts.com' }
  s.social_media_url    = 'http://payler.com'

  s.platform            = :ios, '7.0'
  s.source              = { :git => 'https://github.com/Payler/Payler-iOS-SDK.git', :tag => s.version.to_s }
  s.source_files        = 'PaylerSDK/*.{h,m}'
  s.ios.resource       = 'PaylerSDK/PaylerSDK.bundle'

  s.requires_arc = true
  s.dependency 'AFNetworking/NSURLSession', '~> 3.0'
  s.dependency 'AFNetworking/Security', '~> 3.0'
  s.dependency 'AFNetworking/Serialization', '~> 3.0'
end
