module WineBouncer
  module AuthStrategies
    class Swagger

      def endpoint_protected?(context)
        has_authorizations?(context) && !!authorization_type_oauth2(context)
      end

      def has_auth_scopes?(context)
        endpoint_protected?(context) && !authorization_type_oauth2(context).empty?
      end

      def auth_scopes(context)
        authorization_type_oauth2(context).map{ |hash| hash[:scope].to_sym }
      end

      private

      def has_authorizations?(context)
        !!endpoint_authorizations(context)
      end

      def endpoint_authorizations(context)
        context[:authorizations]
      end

      def authorization_type_oauth2(context)
        endpoint_authorizations(context)[:oauth2]
      end

    end
  end
end
