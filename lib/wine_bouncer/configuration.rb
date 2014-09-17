module WineBouncer

  class << self
    attr_accessor :configuration
  end

  class Configuration

    attr_accessor :auth_strategy

    def auth_strategy=(strategy)
      @auth_strategy= strategy
    end

    def auth_strategy
      @auth_strategy || :default
    end

    def require_strategies
      require "wine_bouncer/auth_strategies/#{auth_strategy}"
    end
  end

   def self.configuration
    @configuration || fail(Errors::UnconfiguredError.new)
  end

  def self.configuration=(config)
    @configuration= config
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

  private

  ###
  # Returns a new configuration or existing one.
  ###
  def self.config
    @configuration ||= Configuration.new
  end
end
