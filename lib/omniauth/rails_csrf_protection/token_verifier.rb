require "active_support/configurable"
require "action_controller"

module OmniAuth
  module RailsCsrfProtection
    # Provides a callable method that verifies Cross-Site Request Forgery
    # protection token. This class includes
    # `ActionController::RequestForgeryProtection` directly and utilizes
    # `verified_request?` method to match the way Rails performs token
    # verification in Rails controllers.
    #
    # If you like to learn more about how Rails generate and verify
    # authenticity token, you can find the source code at
    # https://github.com/rails/rails/blob/v5.2.2/actionpack/lib/action_controller/metal/request_forgery_protection.rb#L217-L240.
    class TokenVerifier
      # Inherits config from ActionController::Base.
      # Define _before_ including ActionController::RequestForgeryProtection.
      def self.config
        @_config ||= ActionController::Base.config.inheritable_copy
      end

      include ActiveSupport::Configurable
      include ActionController::RequestForgeryProtection

      # `ActionController::RequestForgeryProtection` contains a few
      # configurable options. As we want to make sure that our configuration is
      # the same as what being set in `ActionController::Base`, we should make
      # our configuration delegate to `ActionController::Base`.
      config.each_key do |key| config.delete(key) end

      # OmniAuth expects us to raise an exception on auth failure.
      self.forgery_protection_strategy = protection_method_class(:exception)

      # Logging from ActionController::RequestForgeryProtection is redundant.
      # OmniAuth logs basically the same message (from the exception).
      self.log_warning_on_csrf_failure = false

      def call(env)
        dup._call(env)
      end

      def _call(env)
        @request = ActionDispatch::Request.new(env.dup)

        verify_authenticity_token
      end

      private

        attr_reader :request
        delegate :params, :session, to: :request

        delegate :logger, to: OmniAuth
    end
  end
end
