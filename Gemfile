# frozen_string_literal: true

source 'https://rubygems.org'

ENV['grape'] ||= '1.3.0'
ENV['rails'] ||= '~> 6.0.0'
ENV['doorkeeper'] ||= '5.0.0'

gem 'rails', ENV['rails']
gem 'sqlite3', ENV['rails'].match?(/5\.\d\.\d/) ? '~> 1.3.6' : '~> 1.4.2'

gem 'doorkeeper', ENV['doorkeeper']
gem 'grape', ENV['grape']

# Specify your gem's dependencies in wine_bouncer.gemspec
gemspec
