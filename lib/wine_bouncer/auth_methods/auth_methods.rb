# frozen_string_literal: true

module WineBouncer
  module AuthMethods
    attr_accessor :doorkeeper_access_token, :resource_owner

    def protected_endpoint=(protected)
      @protected_endpoint = protected
    end

    def protected_endpoint?
      @protected_endpoint
    end

    def client_credential_token?
      @_doorkeeper_access_token.present? && @_doorkeeper_access_token.resource_owner_id.blank?
    end

    def doorkeeper_access_token
      @_doorkeeper_access_token
    end

    def doorkeeper_access_token=(token)
      @_doorkeeper_access_token = token
    end

    def has_resource_owner?
      @_doorkeeper_access_token&.resource_owner_id
    end
  end
end
