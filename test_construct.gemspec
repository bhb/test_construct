# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'test_construct/version'

Gem::Specification.new do |spec|
  spec.name          = "test_construct"
  spec.version       = TestConstruct::VERSION
  spec.authors       = ["Ben Brinckerhoff", "Avdi Grimm"]
  spec.email         = ["ben@bbrinck.com", "avdi@avdi.org"]
  spec.description   = %q{Creates temporary files and directories for testing.}
  spec.summary       = %q{Creates temporary files and directories for testing.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "~> 5.0.8"
end
