# frozen_string_literal: true

require 'generator_spec'
require 'rails_helper'
require 'generators/wine_bouncer/initializer_generator'

RSpec.describe WineBouncer::Generators::InitializerGenerator, type: :generator do
  destination '/tmp/wine_bouncer'

  before do
    prepare_destination
    run_generator
  end

  it 'creates a test initializer' do
    assert_file 'config/initializers/wine_bouncer.rb', /WineBouncer\.configure/
  end
end
