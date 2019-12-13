
package = JSON.parse(File.read(File.join(__dir__, "package.json")))
version = package['version']

Pod::Spec.new do |s|
  s.name             = "RNKakao"
  s.version          = version
  s.summary          = package["description"]
  s.requires_arc = true
  s.license      = 'MIT'
  s.homepage     = 'n/a'
  s.authors      = { "jeffgukang" => "" }
  s.source       = { :git => "https://github.com/humanscape/react-native-kakao-login", :tag => 'v#{version}'}
  s.source_files = 'ios/ReactNativekakao/*.{h,m}'
  s.platform     = :ios, "8.0"
  s.vendored_frameworks = ['ios/KakaoOpenSDK.framework', 'ios/KakaoCommon.framework', 'ios/KakaoLink.framework', 'ios/KakaoMessageTemplate.framework']
  s.dependency 'React-Core'
end
