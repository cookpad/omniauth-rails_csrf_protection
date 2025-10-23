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
      # `ActionController::RequestForgeryProtection` contains a few
      # configurable options. As we want to make sure that our configuration is
      # the same as what being set in `ActionController::Base`, we use
      # `class_attribute` to delegate to `ActionController::Base.config`.
      #
      # This approach replaces the deprecated ActiveSupport::Configurable usage.
      class_attribute :config, default: ActionController::Base.config

      include ActionController::RequestForgeryProtection

      def call(env)
        dup._call(env)
      end

      def _call(env)
        @request = ActionDispatch::Request.new(env.dup)

        unless verified_request?
          raise ActionController::InvalidAuthenticityToken
        end
      end

      private

        attr_reader :request
        delegate :params, :session, to: :request
    end
  end
end
