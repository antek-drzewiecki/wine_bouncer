# frozen_string_literal: true
require 'wine_bouncer/auth_strategies/protected'
module WineBouncer
  module AuthStrategies
    class ProtectedButSwagger < Protected
      def endpoint_protected?
        has_authorizations? && (api_context.env['PATH_INFO'].nil? || !api_context.env['PATH_INFO'].end_with?('swagger'))
      end
    end
  end
end
