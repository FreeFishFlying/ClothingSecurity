Pod::Spec.new do |s|
  s.name         = "Mesh"
  s.version      = "0.0.1"
  s.summary      = "Mesh. universal network access combined with file and images"
  s.description  = "Mesh"
  s.homepage     = "http://kingxt.me"
  s.license      = "MIT"
  s.author       = { "kingxt" => "kingxt4job@gmail.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "http://180.166.126.162:9000/components/Mesh.git" }
  s.preserve_paths = "Mesh/Webp/module.modulemap"
  s.vendored_framework = "Mesh/Webp/WebP.framework"
  s.source_files  = "Mesh/**/*.{swift, h, m}"
  s.dependency "ReactiveSwift"
  s.dependency "XCGLogger"
  s.framework = "CFNetwork"
end
