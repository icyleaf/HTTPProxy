Pod::Spec.new do |spec|
  spec.name          = 'HTTPProxy'
  spec.version       = '0.0.1'
  spec.license       = { :type => 'MIT' }
  spec.homepage      = 'https://github.com/rafaelleao/HTTPProxy'
  spec.authors       = { 'Rafael Leão' => 'rafaeldeleao@gmail.com' }
  spec.summary       = 'some'
  spec.source        = { :git => 'https://github.com/rafaelleao/HTTPProxy.git', :tag => 'v0.0.1' }
  spec.swift_version = '5.0'
  spec.platform      = :ios, '10.0'
  spec.source_files  = 'HTTPProxy/Library/**/*.swift'
  spec.resources     = ['HTTPProxy/Library/**/*.{xib}']
  spec.dependency 'Highlightr'
end
