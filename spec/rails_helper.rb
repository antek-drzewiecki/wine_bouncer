# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
ORM = ENV.fetch('orm', :active_record).to_sym
require 'spec_helper'
require File.expand_path('dummy/config/environment', __dir__)
require 'rspec/rails'
require 'wine_bouncer'
require 'factory_bot'
require 'database_cleaner'

module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end

def orm_name
  orm = Doorkeeper.configuration.orm
  %i[mongoid2 mongoid3 mongoid4].include?(orm.to_sym) ? :mongoid : orm
end

require "shared/orm/#{orm_name}"

FactoryBot.find_definitions

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include ApiHelper, type: :api

  config.use_transactional_fixtures = false

  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  config.before do
    DatabaseCleaner.start
    FactoryBot.lint
    # Doorkeeper.configure { orm :active_record }
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end
