# rubocop:disable Gemspec/RequiredRubyVersion
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
  spec.require_paths = ['lib']

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3'

  spec.add_runtime_dependency 'doorkeeper'
  spec.add_runtime_dependency 'grape'
  spec.add_runtime_dependency 'rails'
end
# rubocop:enable Gemspec/RequiredRubyVersion
