lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wine_bouncer/version'

Gem::Specification.new do |spec|
  spec.name          = 'wine_bouncer'
  spec.version       = WineBouncer::VERSION
  spec.authors       = ['Antek Drzewiecki']
  spec.email         = ['a.drzewiecki@devsquare.nl']
  spec.summary       = "A Ruby gem that allows Oauth2 protection with Doorkeeper for Grape Api's"
  spec.homepage      = 'https://github.com/antek-drzewiecki/wine_bouncer'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 2.7'

  spec.add_runtime_dependency 'doorkeeper'
  spec.add_runtime_dependency 'grape'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'database_cleaner', '~> 2.0'
  spec.add_development_dependency 'factory_bot', '~> 6.2'
  spec.add_development_dependency 'generator_spec', '~> 0.9.0'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'railties'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec-rails', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 1.28'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'yard'
end
