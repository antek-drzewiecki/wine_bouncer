module WineBouncer
  module AuthStrategies
    class Protected < WineBouncer::BaseStrategy

      def endpoint_protected?
        has_authorizations?
      end

      def has_auth_scopes?
        endpoint_authorizations &&
          endpoint_authorizations.has_key?(:scopes) &&
          endpoint_authorizations[:scopes].any?
      end

      def auth_scopes
        endpoint_authorizations[:scopes].map(&:to_sym)
      end

      private

      def nil_authorizations?
        endpoint_authorizations.nil?
      end


      def has_authorizations?
        !nil_authorizations? || api_context.options[:route_options][:oauth2]
      end

      def endpoint_authorizations
        api_context.options[:route_options][:auth]
      end
    end
  end
end
