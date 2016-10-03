# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module WineBouncer
  class OAuth2 < Grape::Middleware::Base
    include Doorkeeper::Grape::Helpers

    def error!(message, status = nil, headers = nil)
      throw :error, message: message, status: status, headers: headers
    end

    ###
    # returns the api context
    ###
    def context
      env['api.endpoint']
    end

    ###
    # Sets and converts a rack request to a ActionDispatch request, which is required for DoorKeeper to function.
    ###
    def request
      ActionDispatch::Request.new(env)
    end

    ############
    # Authorization control.
    ############

    ###
    # returns true if the endpoint is protected, otherwise false
    ###
    def endpoint_protected?
      auth_strategy.endpoint_protected?
    end

    ###
    # Returns all auth scopes from an protected endpoint.
    # [ nil ] if none, otherwise an array of [ :scopes ]
    ###
    def auth_scopes
      auth_strategy.auth_scopes
    end

    ############
    # Grape middleware methods
    ############

    ###
    # Before do.
    ###
    def before
      return if WineBouncer.configuration.disable_block.call

      set_auth_strategy(WineBouncer.configuration.auth_strategy)
      auth_strategy.api_context = context
      #extend the context with auth methods.
      context.extend(WineBouncer::AuthMethods)
      return unless endpoint_protected?

      scopes = auth_scopes
      context.resource_owner = WineBouncer.configuration.defined_resource_owner.call(doorkeeper_token)
      doorkeeper_authorize!(*scopes) unless scopes.include? :false
    end

    ###
    # Strategy
    ###
    attr_reader :auth_strategy

    private

    def set_auth_strategy(strategy)
      @auth_strategy = WineBouncer::AuthStrategies.const_get(strategy.to_s.capitalize).new
    end
  end
end
