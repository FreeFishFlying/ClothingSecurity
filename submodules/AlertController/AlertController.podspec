Pod::Spec.new do |s|
  s.name         = "AlertController"
  s.version      = "0.1"
  s.summary      = "Simple Alert View written in Swift, which can be used as a UIAlertController replacement."
  s.homepage     = "http://180.166.126.162:9000/components/AlertController"
  s.screenshots  = "http://180.166.126.162:9000/components/AlertController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Daiki Okumura" => "kim@liao.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "http://180.166.126.162:9000/components/AlertController", :tag => s.version.to_s }
  s.source_files = "AlertController/**/*.swift"
  s.framework    = "UIKit"
  s.requires_arc = true
  s.resource_bundles = { 'AlertController' => ['AlertController/**/*.{xib}'] }

  s.dependency     'SnapKit'
end
