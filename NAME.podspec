#
# Be sure to run `pod lib lint ${PROJECT_NAME}.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|

  s.name         = "${PROJECT_NAME}"
  s.version      = "0.1.0"
  s.summary      = "A short description of ${PROJECT_NAME}."
  s.homepage     = "https://github.com/${USER_NAME}/${PROJECT_NAME}"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "${USER_NAME}" => "${USER_EMAIL}" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/${USER_NAME}/${PROJECT_NAME}.git", :tag => "#{s.version}" }
  s.source_files = "Sources/**/*"
  s.frameworks   = "UIKit", "Foundation" 
  s.requires_arc = true
  
end
