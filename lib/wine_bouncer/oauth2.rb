# frozen_string_literal: true

module WineBouncer
  class OAuth2 < Grape::Middleware::Base
    include Doorkeeper::Helpers::Controller
    ###
    # returns the api context
    ###
    def context
      env['api.endpoint']
    end

    ############
    # DoorKeeper stuff.
    ############

    ###
    # Sets and converts a rack request to a ActionDispatch request, which is required for DoorKeeper to function.
    ###
    def doorkeeper_request=(env)
      @_doorkeeper_request = ActionDispatch::Request.new(env)
    end

    ###
    # Returns the request context.
    ###
    def request
      @_doorkeeper_request
    end

    ###
    # Returns true if the doorkeeper token is valid, false otherwise.
    ###
    def valid_doorkeeper_token?(*scopes)
      doorkeeper_token&.accessible? && (Doorkeeper.configuration.authenticate_admin.call(context.resource_owner) ||
        doorkeeper_token.includes_scope?(*scopes))
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

    ###
    # This method handles the authorization, raises errors if authorization has failed.
    ###
    def doorkeeper_authorize!(*scopes)
      scopes = Doorkeeper.configuration.default_scopes if scopes.empty?
      unless valid_doorkeeper_token?(*scopes)
        if !doorkeeper_token || !doorkeeper_token.accessible?
          error = Doorkeeper::OAuth::InvalidTokenResponse.from_access_token(doorkeeper_token)
          raise WineBouncer::Errors::OAuthUnauthorizedError, error
        else
          error = Doorkeeper::OAuth::ForbiddenTokenResponse.from_scopes(scopes)
          raise WineBouncer::Errors::OAuthForbiddenError, error
        end
      end
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

      self.doorkeeper_request = env # set request for later use.
      scopes = auth_scopes
      context.resource_owner = WineBouncer.configuration.defined_resource_owner.call(doorkeeper_token)
      doorkeeper_authorize!(*scopes) unless scopes.include? :false
      context.doorkeeper_access_token = doorkeeper_token
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
