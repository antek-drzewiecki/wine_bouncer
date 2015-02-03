require 'grape'
require 'doorkeeper'
require 'wine_bouncer/version'



module WineBouncer
  class << self
    def post_0_9_0_grape?
      Gem::Version.new(Grape::VERSION) > Gem::Version.new('0.9.0')
    end


  end
end

require 'wine_bouncer/dsl'
require 'wine_bouncer/errors'
require 'wine_bouncer/configuration'
require 'wine_bouncer/oauth2'
require 'wine_bouncer/base_strategy'
require 'wine_bouncer/auth_methods/auth_methods'
