module WineBouncer
  module AuthStrategies
    class Default

      def endpoint_protected?(context)
        has_authorizations?(context)
      end

      def has_auth_scopes?(context)
        has_authorizations?(context) && !endpoint_authorizations(context).empty?
      end

      def auth_scopes(context)
        endpoint_authorizations(context).map { |x| x[:scope].to_sym }
      end

      private

      def has_authorizations?(context)
        !!endpoint_authorizations(context)
      end

      def endpoint_authorizations(context)
         context[:auth]
      end
    end
  end
end
