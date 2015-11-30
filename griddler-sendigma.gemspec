# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'griddler/sendigma/version'

Gem::Specification.new do |spec|
  spec.name          = 'griddler-sendigma'
  spec.version       = Griddler::Sendigma::VERSION
  spec.authors       = ['Brian Graham']
  spec.email         = ['bcgraham@gmail.com']

  spec.summary       = %q{Sendgrid adapter for Griddler}
  spec.description   = %q{Adapter for using Sendgrid's Parse API with Griddler.}
  spec.homepage      = 'https://github.com/briancgraham/griddler-sendigma'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'griddler', '>= 1.2.1'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'

end
