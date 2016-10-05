# frozen_string_literal: true

module WineBouncer
  module AuthStrategies
    module Default
      def endpoint_protected?
        @oauth2 ||= context.options.dig(:route_options, :auth)
      end

      def auth_scopes
        return *nil unless endpoint_protected? && endpoint_protected?[:scopes] && endpoint_protected?[:scopes].is_a?(Array)
        endpoint_protected?[:scopes].map(&:to_sym)
      end
    end
  end
end
