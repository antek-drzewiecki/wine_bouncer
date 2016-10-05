# frozen_string_literal: true

module WineBouncer
  module AuthStrategies
    module Swagger
      def endpoint_protected?
        @oauth2 ||= context.options.dig(:route_options, :authorizations, :oauth2)
      end

      def auth_scopes
        return *nil unless endpoint_protected?&.is_a?(Array)
        endpoint_protected?.map { |hash| hash[:scope].to_sym }
      end
    end
  end
end
