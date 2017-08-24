# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wine_bouncer/version'

Gem::Specification.new do |spec|
  spec.name          = 'wine_bouncer'
  spec.version       = WineBouncer::VERSION
  spec.authors       = ['Antek Drzewiecki']
  spec.email         = ['antek.drzewiecki@altran.com']
  spec.summary       = %q{A Ruby gem that allows Oauth2 protection with Doorkeeper for Grape Api's}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'grape', '<= 1.0.0'
  spec.add_runtime_dependency 'doorkeeper', '>= 1.4', '< 4.3'

  spec.add_development_dependency 'railties'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.5.0'
  spec.add_development_dependency 'factory_girl', '~> 4.4.0'
  spec.add_development_dependency 'generator_spec', '~> 0.9.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'database_cleaner', '~> 1.3.0'
  spec.add_development_dependency 'rubocop', '0.41.1'
  spec.add_development_dependency 'yard', '~> 0.8.7'
end
