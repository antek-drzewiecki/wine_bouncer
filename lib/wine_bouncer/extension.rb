module WineBouncer
  module Extension
    def oauth2(*scopes)
      scopes = Doorkeeper.configuration.default_scopes.all if scopes.all? { |x| x.nil? }
      description = if respond_to?(:route_setting) # >= grape-0.10.0
        route_setting(:description) || route_setting(:description, {})
      else
        @last_description ||= {}
      end

      case WineBouncer.configuration.auth_strategy
      when :default
        description[:auth] = { scopes: scopes }
      when :swagger
        description[:authorizations] = { oauth2: scopes.map{|x| {scope: x}} }
      end
    rescue WineBouncer::Errors::UnconfiguredError
      description[:auth] = { scopes: scopes }
      description[:authorizations] = { oauth2: scopes.map{|x| {scope: x}} }
    end

    Grape::API.extend self
  end
end
