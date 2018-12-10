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
  s.summary          = 'A short description of FIXiT.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
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
  # s.dependency 'AFNetworking', '~> 2.3'
end
