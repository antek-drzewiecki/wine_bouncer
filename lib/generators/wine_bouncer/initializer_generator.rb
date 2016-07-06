# frozen_string_literal: true

module WineBouncer
  module Generators
    class InitializerGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Creates a sample WineBouncer initializer.'
      def copy_initializer
        copy_file 'wine_bouncer.rb', 'config/initializers/wine_bouncer.rb'
      end
    end
  end
end
