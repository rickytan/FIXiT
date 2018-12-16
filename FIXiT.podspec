#
# Be sure to run `pod lib lint FIXIT.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FIXiT'
  s.version          = '0.1.0'
  s.summary          = 'Yet another Javascript fixing solution.'
  s.description      = <<-DESC
A Javascript Proxy Object based hotfix solution for Objective-C. With the power
of KVC, your may access and update Objective-C class members at runtime.
Simple to use and integrate. You can write your js code in a more natural way.
                       DESC

  s.homepage         = 'https://github.com/rickytan/FIXiT'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rickytan' => 'ricky.tan.xin@gmail.com' }
  s.source           = { :git => 'https://github.com/rickytan/FIXiT.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'FIXiT/Classes/**/*'
  s.resources = 'FIXiT/Assets/*.js'
  s.public_header_files = 'FIXiT/Classes/**/FIXiT.h'
  s.frameworks = 'Foundation', 'JavaScriptCore'
  s.libraries = 'c++'
end
