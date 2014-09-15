module WineBouncer
  module Errors
    class OAuthUnauthorizedError < StandardError; end
    class OAuthForbiddenError < StandardError; end
  end
end
