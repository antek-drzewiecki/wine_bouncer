# frozen_string_literal: true

module WineBouncer
  module Helpers
    def object_attr_accessor(obj, attr_name)
      obj.__send__(:define_singleton_method, "#{attr_name}=".to_sym) do |value|
        instance_variable_set("@#{attr_name}", value)
      end

      obj.__send__(:define_singleton_method, attr_name.to_sym) do
        instance_variable_get("@#{attr_name}")
      end
    end

    def error!(message, status = nil, headers = nil)
      throw :error, message: message, status: status, headers: headers
    end

    def configuration
      @configuration ||= WineBouncer.configuration
    end

    def auth_strategy
      @auth_strategy ||= configuration.auth_strategy
    end

    def fetch_scopes(route_options)
      auth_strategy.each do |strategy|
        __send__("fetch_#{strategy}_scopes", route_options)
      end
    end

    def fetch_swagger_2_scopes(route_options)
      swagger_scopes = route_options[:security]
      route_options[:scopes] |= swagger_scopes.values.flat_map if swagger_scopes && swagger_scopes.is_a?(Array)
    end

    def fetch_swagger_scopes(route_options)
      swagger_scopes = route_options.try(:[], :authorizations).try(:[], :oauth2)
      return unless swagger_scopes && swagger_scopes.is_a?(Array)
      route_options[:scopes] ||= []
      route_options[:scopes] |= swagger_scopes.map { |hash| hash[:scope].to_sym }
    end

    def fetch_protected_scopes(route_options)
      # :auth is a legacy key, would be deprecated
      route_options[:scopes] ||= []
      if route_options.key?(:auth)
        route_options[:scopes] |= [false] if route_options[:auth] == false
        legacy_scopes = route_options[:auth].try(:[], :scopes)
        route_options[:scopes] |= legacy_scopes.map(&:to_sym) if legacy_scopes && legacy_scopes.is_a?(Array)
      end
      #---END of legacy code for :auth key

      route_options[:scopes] = Doorkeeper.configuration.default_scopes.all if route_options[:scopes].blank?
    end
    alias fetch_default_scopes fetch_protected_scopes
  end
end
