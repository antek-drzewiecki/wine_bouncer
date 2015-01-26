module WineBouncer
  module AuthStrategies
    class Protected

      def endpoint_protected?(context)
        has_authorizations?(context)
      end

      def has_auth_scopes?(context)
        endpoint_authorizations(context) && 
          endpoint_authorizations(context).has_key?(:scopes) && 
          endpoint_authorizations(context)[:scopes].any?
      end

      def auth_scopes(context)
        endpoint_authorizations(context)[:scopes].map(&:to_sym)
      end

      private

      def nil_authorizations?(context)
        endpoint_authorizations(context).nil?
      end


      def has_authorizations?(context)
        nil_authorizations?(context) || endpoint_authorizations(context)
      end

      def endpoint_authorizations(context)
         context[:auth]
      end
    end
  end
end
