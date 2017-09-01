# frozen_string_literal: true

source 'https://rubygems.org'

ENV['grape'] ||= '1.0.0'
ENV['rails'] ||= '5.0.0'
ENV['doorkeeper'] ||= '4.0.0'

ruby '>= 2.2.2' if ENV['rails'][0].to_i > 4

gem 'rails', ENV['rails']

gem 'activerecord'
gem 'grape', ENV['grape']
gem 'doorkeeper', ENV['doorkeeper']

gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'simplecov', :require => false, :group => :test

# Specify your gem's dependencies in wine_bouncer.gemspec
gemspec
