Pod::Spec.new do |s|
  s.name         = "Bifrost"
  s.version      = "1.0.0"
  s.summary      = "Bifrost"
  s.description  = <<-DESC
                   A delightful library for app business modular architecture.
                   DESC
  s.homepage     = "https://github.com/youzan/Bifrost/wikis/home"
  s.license      = 'MIT'
  s.author       = { "JackieYang" => "yangke@youzan.com" }
  s.source       = { :git => "https://github.com/youzan/Bifrost.git", :tag => s.version.to_s }
  s.source_files = 'Bifrost/Lib/*.{h,m}'
  s.framework   = 'UIKit'
  s.requires_arc = true
  s.ios.deployment_target = "7.0"
end
