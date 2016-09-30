# frozen_string_literal: true

module WineBouncer
  module AuthStrategies
    class Protected < WineBouncer::BaseStrategy
      def endpoint_protected?
        has_authorizations?
      end

      def auth_scopes
        return *nil unless endpoint_authorizations && endpoint_authorizations[:scopes].present? &&
          endpoint_authorizations[:scopes].is_a?(Array)
        endpoint_authorizations[:scopes].map(&:to_sym)
      end

      private

      def nil_authorizations?
        endpoint_authorizations.nil?
      end

      # returns true if an authorization hash has been found
      # First it checks for the old syntax, then for the new.
      def has_authorizations?
        (nil_authorizations? || !!endpoint_authorizations) && scope_keys?
      end

      # if false or nil scopes are entered the authorization should be skipped.
      # nil_authorizations? is used to check against the legacy hash.
      def scope_keys?
        nil_authorizations? || endpoint_authorizations[:scopes] != [false]
      end

      def endpoint_authorizations
        @oauth2 ||= api_context.options.dig(:route_options, :auth)
      end
    end
  end
end
