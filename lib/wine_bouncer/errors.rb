# frozen_string_literal: true

module WineBouncer
  module Errors
    class UnconfiguredError < StandardError; end

    class OAuthUnauthorizedError < StandardError
      attr_reader :response
      def initialize(response)
        super(response.try(:description))
        @response = response
      end
    end

    class OAuthForbiddenError < StandardError
      attr_reader :response
      def initialize(response)
        super(response.try(:description))
        @response = response
      end
    end
  end
end
