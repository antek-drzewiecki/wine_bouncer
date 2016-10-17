# frozen_string_literal: true

WineBouncer.configure do |config|
  config.auth_strategy = %i(default) # :protected, :swagger and :swagger_2 currently implemented

  config.define_resource_owner do |doorkeeper_access_token|
    User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
  end
end
