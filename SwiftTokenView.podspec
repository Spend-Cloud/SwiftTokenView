Pod::Spec.new do |s|
    s.name             = 'SwiftTokenView'
    s.version          = '0.0.1'
    s.summary          = 'SwiftTokenView is a lightweight package that lets you create easy to use Token views to use in UIKit or SwiftUI.'
  
    s.homepage         = 'https://github.com/Spend-Cloud/SwiftTokenView'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Visma | ProActive' => '' }
    s.source           = { :git => 'https://github.com/Spend-Cloud/SwiftTokenView.git', :tag => s.version.to_s }
  
    s.ios.deployment_target = '13.0'
    
    s.swift_version = '5.0'
  
    s.source_files = 'Sources/SwiftTokenView/**/*'
  end