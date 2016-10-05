# frozen_string_literal: true

module WineBouncer
  module Extension
    def oauth2(*scopes)
      description = route_setting(:description) || route_setting(:description, {})

      # Create :security hash if missing: Open API(Swagger) 2.0 compliance
      description[:security] = Array.new unless description[:security]
      security = description[:security]
      security.unshift({ inline: scopes })
      api_scopes_undefined = security.all? { |x|
        x.each_value { |y|
          y.empty? || y.all? { |z| z.blank?}
        }
      }

      if WineBouncer.configuration.auth_strategy == :protected
        # If no scopes defined on the API, use default Doorkeeper scopes, because of :protected auth_strategy
        security.unshift({ doorkeeper: Doorkeeper.configuration.default_scopes.all }) if api_scopes_undefined
        description[:protected] = true
      else
        description[:protected] = false if api_scopes_undefined
      end
    end

    Grape::API.extend self
  end
end
