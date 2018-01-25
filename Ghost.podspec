Pod::Spec.new do |s|
  s.name             = 'Ghost'
  s.version          = '1.0.0'
  s.summary          = 'Versatile HTTP networking framework written in Swift.'

  s.homepage         = 'https://github.com/Meniny/Ghost'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.authors          = { 'Elias Abel' => 'admin@meniny.cn' }
  s.source           = { :git => 'https://github.com/Meniny/Ghost.git', :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn'
  # s.screenshot       = ''

  s.swift_version    = "4.0"

  s.ios.deployment_target = '8.0'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'

  s.framework        = 'Foundation'
  s.module_name      = 'Ghost'
  s.default_subspecs = 'Core', 'URLSession', 'NightWatch'

  s.subspec 'Core' do |ss|
    ss.source_files  = "Ghost/Core/*.{h,swift}"
  end

  s.subspec 'URLSession' do |ss|
    ss.dependency 'Ghost/Core'
    ss.source_files  = "Ghost/URLSession/*.{h,swift}"
  end
  
  s.subspec 'NightWatch' do |ss|
    ss.dependency 'Ghost/NightWatch'
    ss.source_files  = "Ghost/NightWatch/*.{h,swift}"
  end
end
