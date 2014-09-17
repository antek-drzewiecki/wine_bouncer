module WineBouncer
  module Errors
    class UnconfiguredError < StandardError; end
    class OAuthUnauthorizedError < StandardError; end
    class OAuthForbiddenError < StandardError; end
  end
end
