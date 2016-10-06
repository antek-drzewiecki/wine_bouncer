# frozen_string_literal: true

module WineBouncer

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :auth_strategy, :defined_resource_owner

    def auth_strategy
      @auth_strategy ||= :default
    end

    def require_strategies
      require "wine_bouncer/auth_strategies/#{auth_strategy}"
    end

    def define_resource_owner &block
      @defined_resource_owner = block || -> (doorkeeper_access_token) {
        User.find(doorkeeper_access_token.resource_owner_id) if doorkeeper_access_token
      }
    end

    # when the block evaluates to true, WineBouncer should be disabled
    # if no block is provided, WineBouncer is always enabled
    def disable(&block)
      @disable_block = block
    end

    def disable_block
      @disable_block || ->() { false }
    end
  end

  def self.configuration
    @configuration ||= self.configure
  end

  def self.configuration=(config)
    @configuration = config
    @configuration.require_strategies
  end

  ###
  # Configure block.
  # Requires all strategy specific files.
  ###
  def self.configure
    yield config if block_given?
    config.require_strategies
    config.define_resource_owner unless block_given?
    WineBouncer::OAuth2.include WineBouncer::AuthStrategies.const_get(config.auth_strategy.to_s.capitalize)
    config
  end

  ###
  # Returns a new configuration or existing one.
  ###
  def self.config
    @configuration ||= Configuration.new
  end

  private_class_method :config
end
