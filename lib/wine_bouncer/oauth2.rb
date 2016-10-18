# frozen_string_literal: true

require 'doorkeeper/grape/helpers'
require 'wine_bouncer/helpers'

module WineBouncer
  class OAuth2 < Grape::Middleware::Base
    include Doorkeeper::Grape::Helpers
    include WineBouncer::Helpers

    attr_accessor :context

    ###
    # Sets and converts a rack request to a ActionDispatch request, which is required for DoorKeeper to function.
    ###
    def request
      ActionDispatch::Request.new(env)
    end

    def resource_owner_to_context
      # Create attr_accesor :resource_owner in the endpoint's context
      @context = env['api.endpoint']
      object_attr_accessor(context, 'resource_owner')
      context.resource_owner = configuration.defined_resource_owner.call(doorkeeper_token)
    end

    def default_strategy_only?
      auth_strategy.include?(:default) && auth_strategy.size == 1
    end

    ############
    # Grape middleware methods
    ############

    def before
      return if configuration.disable_block.call

      resource_owner_to_context
      route_options = context.options[:route_options]

      # For unprotected route do not fetch scopes if only :default auth_strategy is specified,
      unless default_strategy_only? && !route_options.key?(:auth) # :auth is a legacy key, would be deprecated
        fetch_scopes(route_options) unless route_options.key?(:protected)
      end

      auth_scopes = route_options[:scopes]

      return if (auth_scopes.nil? && !auth_strategy.include?(:protected)) ||
          auth_scopes.include?('false') || auth_scopes.include?(false)
      doorkeeper_authorize!(*auth_scopes)
    end
  end
end
