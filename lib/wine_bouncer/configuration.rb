# frozen_string_literal: true

module WineBouncer

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :auth_strategy, :defined_resource_owner

    def auth_strategy
      @auth_strategy || :default
    end

    def require_strategies
      require "wine_bouncer/auth_strategies/#{auth_strategy}"
    end

    def define_resource_owner &block
      raise ArgumentError, 'define_resource_owner expects a block in the configuration' unless block_given?
      @defined_resource_owner = block
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
    raise ArgumentError, 'WineBouncer is not configured!' if @configuration.blank?
    @configuration
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
    yield(config)
    config.require_strategies
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
