module WineBouncer
  class OAuth2 < Grape::Middleware::Base

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
    def doorkeeper_request
      @_doorkeeper_request
    end

    ###
    # Authenticates from a request and returns a valid or invalid token.
    ###
    def doorkeeper_token
      @_doorkeeper_token ||= Doorkeeper.authenticate(doorkeeper_request,Doorkeeper.configuration.access_token_methods)
    end

    ###
    # Returns true if the doorkeeper token is valid, false otherwise.
    ###
    def valid_doorkeeper_token?(*scopes)
      doorkeeper_token && doorkeeper_token.acceptable?(scopes)
    end

    ############
    # Authorization control.
    ############

    ###
    # Returns true if the Api endpoint, method is configured as an protected method, false otherwise.
    ###
    def valid_route_context?
      context && context.options && context.options[:route_options]
    end

    def route_context
      context.options[:route_options]
    end

    ###
    # returns true if the endpoint is protected, otherwise false
    ###
    def endpoint_protected?
      auth_strategy.endpoint_protected?(route_context)
    end

    ###
    # Returns all auth scopes from an protected endpoint.
    # [ nil ] if none, otherwise an array of [ :scopes ]
    ###
    def auth_scopes
      return *nil unless auth_strategy.has_auth_scopes?(route_context)
      auth_strategy.auth_scopes(route_context)
    end

    ###
    # This method handles the authorization, raises errors if authorization has failed.
    ###
    def doorkeeper_authorize!(*scopes)
      scopes = Doorkeeper.configuration.default_scopes if scopes.empty?
      unless valid_doorkeeper_token?(*scopes)
        if !doorkeeper_token || !doorkeeper_token.accessible?
          error = Doorkeeper::OAuth::InvalidTokenResponse.from_access_token(doorkeeper_token)
          raise WineBouncer::Errors::OAuthUnauthorizedError, 'unauthorized'
        else
          error = Doorkeeper::OAuth::ForbiddenTokenResponse.from_scopes(scopes)
          raise WineBouncer::Errors::OAuthForbiddenError, "missing permissions"
        end

        # headers.merge!(error.headers.reject { |k| ['Content-Type'].include? k })
        # doorkeeper_error_renderer(error, options)
      end
    end

    ############
    # Grape middleware methods
    ############

    ###
    # Before do.
    ###
    def before
      set_auth_strategy(WineBouncer.configuration.auth_strategy)
      #extend the context with auth methods.
      context.extend(WineBouncer::AuthMethods)
      context.protected_endpoint = endpoint_protected?
      return unless context.protected_endpoint?
      self.doorkeeper_request= env # set request for later use.
      doorkeeper_authorize! *auth_scopes
      context.doorkeeper_access_token = doorkeeper_token
    end

    ###
    # Strategy
    ###
    def auth_strategy
      @auth_strategy
    end

    private

    def set_auth_strategy(strategy)
      @auth_strategy = WineBouncer::AuthStrategies.const_get("#{strategy.to_s.capitalize}").new
    end

  end
end
