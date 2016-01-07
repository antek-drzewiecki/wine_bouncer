require 'generator_spec'
require 'rails_helper'
require 'spec_helper'
require 'generators/wine_bouncer/initializer_generator'

describe WineBouncer::Generators::InitializerGenerator, type: :generator do
  destination '/tmp'

  before do
    prepare_destination
    run_generator
  end

  it 'creates a test initializer' do
    assert_file 'config/initializers/wine_bouncer.rb', /WineBouncer\.configure/
  end
end
