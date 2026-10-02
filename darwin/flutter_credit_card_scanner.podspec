Pod::Spec.new do |s|
  s.name             = 'flutter_credit_card_scanner'
  s.version          = '0.13.0'
  s.summary          = 'On-device credit card scanner.'
  s.description      = 'Reads a card number and expiry from the camera.'
  s.homepage         = 'https://github.com/nimr77/Flutter_credit_card_scanner'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Bizkey Tech' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'flutter_credit_card_scanner/Sources/flutter_credit_card_scanner/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '15.5'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end