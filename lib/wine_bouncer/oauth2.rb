module WineBouncer
  class OAuth2 < Grape::Middleware::Base

    ###
    # returns the api context
    ###
    def context
      env['api.endpoint']
    end

    ###
    # DoorKeeper stuff.
    ###

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

    ###
    # Authorization control.
    ###

    ###
    # Returns true if the Api endpoint, method is configured as an protected method, false otherwise.
    ###
    def has_authorizations?
      context && context.options && context.options[:route_options] && endpoint_authorizations
    end

    ###
    # Returns the endpoint authorizations hash.
    # This hash contains all authorization methods.
    ###
    def endpoint_authorizations
      @_authorizations ||= context.options[:route_options][:authorizations]
    end

    ###
    # returns true if the endpoint is protected, otherwise false
    # Currently it only accepts oauth2.
    ###
    def endpoint_protected?
      has_authorizations? && !!endpoint_authorizations[:oauth2]
    end

    ###
    # Returns all auth scopes from an protected endpoint.
    # [ nil ] if none, otherwise an array of [ :scopes ]
    ###
    def auth_scopes
      return *nil if endpoint_authorizations[:oauth2].empty?
      endpoint_authorizations[:oauth2].map{|hash| hash[:scope].to_sym}
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

    ###
    # Grape middleware methods
    ###

    ###
    # Before do.
    ###
    def before
      return unless endpoint_protected?
      self.doorkeeper_request= env # set request for later use.
      doorkeeper_authorize! *auth_scopes
      env['api.endpoint'].extend(WineBouncer::AuthMethods)
      env['api.endpoint'].doorkeeper_access_token = doorkeeper_token
    end

  end
end