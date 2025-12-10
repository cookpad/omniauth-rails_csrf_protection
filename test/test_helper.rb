$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

# Simple Rails application template, based on Rails issue template
# https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller.rb

# Helper method to silence warnings from bundler/inline
def silence_warnings
  old_verbose, $VERBOSE = $VERBOSE, nil
  yield
ensure
  $VERBOSE = old_verbose
end

silence_warnings do
  require "bundler/inline"
  require "logger"

  # Define dependencies required by this test app
  gemfile do
    source "https://rubygems.org"

    if ENV["RAILS_VERSION"] == "edge"
      gem "rails", git: "https://github.com/rails/rails.git", branch: "main"
    else
      gem "rails"
    end

    if RUBY_VERSION >= "3.4"
      gem "bigdecimal"
      gem "drb"
      gem "mutex_m"
    end

    gem "capybara"
    gem "omniauth"
    gem "omniauth-rails_csrf_protection", path: File.expand_path("..", __dir__)
  end
end

puts "Running test on Ruby #{RUBY_VERSION} against Rails #{Rails.version}"

require "rack/test"
require "action_controller/railtie"
require "minitest/autorun"

# Build a test application which uses OmniAuth
class TestApp < Rails::Application
  config.root = __dir__
  config.session_store :cookie_store, key: "cookie_store_key"
  config.secret_key_base = "secret_key_base"
  config.eager_load = false
  config.hosts = []

  # This allow us to send all logs to STDOUT if we run test wth `VERBOSE=1`
  config.logger = if ENV["VERBOSE"]
                    Logger.new($stdout)
                  else
                    Logger.new("/dev/null")
                  end
  Rails.logger = config.logger
  OmniAuth.config.logger = Rails.logger

  # Setup a simple OmniAuth configuration with only developer provider
  config.middleware.use OmniAuth::Builder do
    provider :developer
  end

  # Silence the deprecation warning in Rails 8.0.x
  if Gem::Requirement.new("~> 8.0.x").satisfied_by?(Rails.gem_version)
    config.active_support.to_time_preserves_timezone = :zone
  end

  # We need to call initialize! to run all railties
  initialize!

  # Define our custom routes. This needs to be called after initialize!
  routes.draw do
    get "sign_in" => "application#sign_in"
    get "token" => "application#token"
    get "auth/failure" => "application#failure"
    match "auth/developer/callback" => "application#callback", :via => [:get, :post]
  end
end

# A small test controller which we use to retrive the valid authenticity token
class ApplicationController < ActionController::Base
  def token
    render plain: form_authenticity_token
  end

  def sign_in
    render inline: <<~ERB
      <%= button_to "Sign in", "/auth/developer", method: :post %>
    ERB
  end

  def failure
    render plain: params[:message]
  end

  def callback
    render plain: "Hello #{params[:name]} (#{params[:email]})!"
  end
end
