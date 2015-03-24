# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/registrar/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-registrar"
  spec.version       = OmniAuth::Registrar::VERSION
  spec.authors       = ["Jan Owiesniak"]
  spec.email         = ["jan@featurefabrik.de"]
  spec.summary       = %q{OmniAuth strategy to simplify sign up / sign in process}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
