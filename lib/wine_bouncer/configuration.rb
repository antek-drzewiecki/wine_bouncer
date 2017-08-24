# frozen_string_literal: true

module WineBouncer

  class << self
    attr_accessor :configuration
  end

  class Configuration
    attr_accessor :auth_strategy
    attr_accessor :defined_resource_owner
    attr_writer :auth_strategy

    def auth_strategy
      @auth_strategy || :default
    end

    def require_strategies
      require "wine_bouncer/auth_strategies/#{auth_strategy}"
    end

    def define_resource_owner &block
      raise(ArgumentError, 'define_resource_owner expects a block in the configuration') unless block_given?
      @defined_resource_owner = block
    end

    def defined_resource_owner
      raise(Errors::UnconfiguredError, 'Please define define_resource_owner to configure the resource owner') unless @defined_resource_owner
      @defined_resource_owner
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
    @configuration || raise(Errors::UnconfiguredError.new)
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
    config
  end

  private_class_method

  ###
  # Returns a new configuration or existing one.
  ###
  def self.config
    @configuration ||= Configuration.new
  end
end
