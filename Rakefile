# frozen_string_literal: true

require 'bundler/gem_tasks'

# rspec task
require 'rspec/core/rake_task'
desc 'Run all specs'
RSpec::Core::RakeTask.new(:spec)

# rubocop task
require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task default: %i[spec rubocop]
