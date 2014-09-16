module WineBouncer
  module AuthMethods
    attr_accessor :doorkeeper_access_token

    def current_user
      User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
    end

    def doorkeeper_access_token
      @_doorkeeper_access_token
    end

    def doorkeeper_access_token=(token)
      @_doorkeeper_access_token = token
    end

    def has_doorkeeper_token?
      !!@_doorkeeper_access_token
    end

    def has_resource_owner?
      has_doorkeeper_token? && !!doorkeeper_access_token.resource_owner_id
    end
  end
end
