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

  s.source_files = 'BCMarkdown/Sources/**/*.swift'
  s.subspec 'cmark' do |cmark|
    cmark.vendored_libraries = 'BCMarkdown/cmark/libBCCmark.a'
    cmark.source_files = 'BCMarkdown/cmark/include/*.h'
  end
  # s.preserve_paths = 'BCMarkdown/cmark/include/*.h', 'BCMarkdown/BCMarkdown.h'
end