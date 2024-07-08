Pod::Spec.new do |s|
  s.name             = 'FFTextView'
  s.version          = '0.1.0'
  s.summary          = 'A short description of FFTextView.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/24KYang/FFTextView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '四五20' => '916391479@qq.com' }
  s.source           = { :git => 'https://github.com/24KYang/FFTextView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.frameworks = 'UIKit'

  s.source_files = 'FFTextView/**/*'
  
  s.dependency 'Masonry'
  
end
