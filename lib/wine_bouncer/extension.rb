# frozen_string_literal: true

module WineBouncer
  module Extension
    include WineBouncer::Helpers

    def oauth2(*scopes)
      description = route_setting(:description) || route_setting(:description, {})

      # Fetch scopes for all defined auth_strategies and make them a uniq set with inline defined scopes
      # description[:scopes] = (scopes | fetch_scopes(description)).uniq
      description[:scopes] = scopes

      fetch_scopes(description).uniq
      description[:protected] = !description[:scopes].nil?
    end

    Grape::API.extend self
  end
end
