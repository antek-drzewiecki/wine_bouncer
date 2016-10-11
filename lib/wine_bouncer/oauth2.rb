# frozen_string_literal: true

require 'doorkeeper/grape/helpers'

module WineBouncer
  class OAuth2 < Grape::Middleware::Base
    include Doorkeeper::Grape::Helpers

    attr_accessor :context

    def error!(message, status = nil, headers = nil)
      throw :error, message: message, status: status, headers: headers
    end

    ###
    # Sets and converts a rack request to a ActionDispatch request, which is required for DoorKeeper to function.
    ###
    def request
      ActionDispatch::Request.new(env)
    end

    ############
    # Grape middleware methods
    ############

    def before
      return if WineBouncer.configuration.disable_block.call

      @context = env['api.endpoint']
      WineBouncer::Helpers.object_attr_accessor(context, 'resource_owner')
      context.resource_owner = WineBouncer.configuration.defined_resource_owner.call(doorkeeper_token)
      route_options = context.options[:route_options]
      scopes = []
      if WineBouncer.configuration.auth_strategy == :protected && !route_options.key?(:protected)
        route_options[:protected] = true
        scopes.unshift(Doorkeeper.configuration.default_scopes.all)
      end
      return unless route_options[:protected]
      # scopes = auth_scopes
      doorkeeper_authorize!(*scopes) unless scopes.include? :false
    end
  end
end
