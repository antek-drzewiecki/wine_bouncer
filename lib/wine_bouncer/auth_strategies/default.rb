module WineBouncer
  module AuthStrategies
    class Default < ::WineBouncer::BaseStrategy

      def endpoint_protected?
        !!endpoint_authorizations
      end

      def has_auth_scopes?
        !!endpoint_authorizations &&
            endpoint_authorizations.has_key?(:scopes) &&
            !endpoint_authorizations[:scopes].empty?
      end

      def auth_scopes
        endpoint_authorizations[:scopes].map(&:to_sym)
      end

      private

      def endpoint_authorizations
          api_context.options[:route_options][:auth]
      end
    end
  end
end
