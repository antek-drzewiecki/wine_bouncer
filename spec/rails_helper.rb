# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
ORM = (ENV['orm'] || :active_record).to_sym
require 'spec_helper'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'wine_bouncer'
require 'factory_girl'
require 'database_cleaner'
require "codeclimate-test-reporter"

CodeClimate::TestReporter.start

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
#ActiveRecord::Migration.maintain_test_schema!

module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
end


require "shared/orm/#{Doorkeeper.configuration.orm_name}"

FactoryGirl.find_definitions



RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.

  config.include FactoryGirl::Syntax::Methods
  config.include ApiHelper, :type=>:api

  config.use_transactional_fixtures = false


  config.infer_spec_type_from_file_location!

  config.infer_base_class_for_anonymous_controllers = false

  config.before do
    DatabaseCleaner.start
    FactoryGirl.lint
   # Doorkeeper.configure { orm :active_record }
  end

  config.after do
    DatabaseCleaner.clean
  end

  config.order = 'random'
end


