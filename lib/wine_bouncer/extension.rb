# frozen_string_literal: true

module WineBouncer
  module Extension
    def oauth2(*scopes)
      # Create :description hash and :security array if missing: Open API(Swagger) 2.0 compliance
      description = route_setting(:description) || route_setting(:description, {})
      description[:security] = [] unless description[:security]

      # If no scopes defined on the API, use default Doorkeeper scopes
      scopes.unshift(Doorkeeper.configuration.default_scopes.all) if scopes.empty?
      description[:security].unshift({ inline: scopes })
      if scopes.include?('false')
        description[:protected] = false
      else
        description[:protected] = true
      end
    end

    Grape::API.extend self
  end
end
