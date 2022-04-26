# frozen_string_literal: true

module WineBouncer
  module AuthMethods
    def protected_endpoint=(protected)
      @protected_endpoint = protected
    end

    def protected_endpoint?
      @protected_endpoint || false
    end

    def resource_owner
      instance_eval(&WineBouncer.configuration.defined_resource_owner)
    end

    def client_credential_token?
      has_doorkeeper_token? && doorkeeper_access_token.resource_owner_id.nil?
    end

    def doorkeeper_access_token
      @_doorkeeper_access_token
    end

    def doorkeeper_access_token=(token)
      @_doorkeeper_access_token = token
    end

    def has_doorkeeper_token?
      !@_doorkeeper_access_token.nil?
    end

    def has_resource_owner?
      has_doorkeeper_token? && !!doorkeeper_access_token.resource_owner_id
    end
  end
end
