module WineBouncer
  module AuthStrategies
    class Swagger < ::WineBouncer::BaseStrategy

      def endpoint_protected?
        has_authorizations? && !!authorization_type_oauth2
      end

      def has_auth_scopes?
        endpoint_protected? && !authorization_type_oauth2.empty?
      end

      def auth_scopes
        authorization_type_oauth2.map { |hash| hash[:scope].to_sym }
      end

      private

      def has_authorizations?
        !!endpoint_authorizations
      end

      def endpoint_authorizations
         api_context.options[:route_options][:authorizations]
      end

      def authorization_type_oauth2
        endpoint_authorizations[:oauth2]
      end
    end
  end
end
