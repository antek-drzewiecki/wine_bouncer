module WineBouncer
  module Extension
    def oauth2(*scopes)
      scopes = Array(scopes)
      description = if respond_to?(:route_setting) # >= grape-0.10.0
        route_setting(:description) || route_setting(:description, {})
      else
        @last_description ||= {}
      end
      # case WineBouncer.configuration.auth_strategy
      # when :default
      description[:auth] = { scopes: scopes }
      # when :swagger
      description[:authorizations] = { oauth2: scopes.map{|x| {scope: x}} }
      # end
    end

    Grape::API.extend self
  end
end
