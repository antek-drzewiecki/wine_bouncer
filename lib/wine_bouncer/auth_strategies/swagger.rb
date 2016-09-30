# frozen_string_literal: true

module WineBouncer
  module AuthStrategies
    class Swagger < ::WineBouncer::BaseStrategy
      def endpoint_protected?
        @oauth2 ||= api_context.options.dig(:route_options, :authorizations, :oauth2)
      end

      def has_auth_scopes?
        endpoint_protected? && !endpoint_protected?.empty?
      end

      def auth_scopes
        endpoint_protected?.map { |hash| hash[:scope].to_sym }
      end
    end
  end
end
