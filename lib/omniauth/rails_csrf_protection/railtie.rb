require "omniauth/rails_csrf_protection/token_verifier"

module OmniAuth
  module RailsCsrfProtection
    class Railtie < Rails::Railtie
      initializer "omniauth-rails_csrf_protection.initialize" do
        OmniAuth.config.allowed_request_methods = [:post]
        OmniAuth.config.before_request_phase = TokenVerifier.new
      end
    end
  end
end
