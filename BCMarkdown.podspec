Pod::Spec.new do |s|
  s.name             = "BCMarkdown"
  s.version          = "0.1.0"
  s.summary          = "BCMarkdown"
  s.homepage         = "https://bearychat.com/"
  s.license          = { :type => 'MIT' }
  s.author           = { "lang" => "lang@bearyinnovative.com" }
  s.source           = { :git => "https://github.com/bearyinnovative/BCMarkdown.git", :brach => 'lang' }

  # Platform setup
  s.requires_arc = true  
  s.ios.deployment_target     = "9.0"
  s.swift_version = '4.0'

  s.source_files = 'BCMarkdown/Sources/**/*.swift', 'cmark/*.c', 'cmark/*.inc'
  s.private_header_files = 'cmark/*.h'
  s.preserve_paths = 'BCMarkdown/module.modulemap', 'cmark/*.h'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/BCMarkdown/BCMarkdown/' }
end