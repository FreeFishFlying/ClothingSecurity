Pod::Spec.new do |spec|
  spec.name         = 'MediaEditorKit'
  spec.version      = '0.1.0'
  spec.license      =  { :type => 'BSD' }
  spec.homepage     = 'https://github.com/kingxt/MediaEditorKit'
  spec.authors      = { 'kingxt' => 'kingxt@163.com' }
  spec.summary      = 'EMediaEditorKit'
  spec.source       = { :git => 'http://gitlab.xiaoheiban.cn/components/MediaEditorKit.git' }
  spec.source_files = 'MediaEditorKit/**/*.{h,m,mm,cpp}'
  spec.resources    = 'MediaEditorKit/**/*.bundle'
  spec.requires_arc = true
  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.8'
  spec.tvos.deployment_target = '9.0'
  spec.libraries = 'stdc++'
  spec.dependency  'pop'
end