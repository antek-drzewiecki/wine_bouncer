# frozen_string_literal: true

module WineBouncer
  module Extension
    def oauth2(*scopes)
      scopes = Doorkeeper.configuration.default_scopes.all if scopes.all? { |x| x.nil? }
      description = route_setting(:description) || route_setting(:description, {})
      # case WineBouncer.configuration.auth_strategy
      # when :default
      description[:auth] = { scopes: scopes }
      # when :swagger
      description[:authorizations] = { oauth2: scopes.map { |x| { scope: x } } }
      # end
    end

    Grape::API.extend self
  end
end
