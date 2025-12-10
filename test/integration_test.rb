require "test_helper"
require "capybara/rails"
require "capybara/minitest"

class IntegrationTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  # We are using this `:per_form_csrf_tokens` as a way to test that we have
  # setup method delegation properly to prevent regression, as Railtie sets
  # this configuration to true afterward and causes them to be out-of-sync.
  setup do
    @original_per_form_csrf_tokens = \
      ActionController::Base.config[:per_form_csrf_tokens]
    ActionController::Base.config[:per_form_csrf_tokens] = true
  end

  teardown do
    ActionController::Base.config[:per_form_csrf_tokens] = \
      @original_per_form_csrf_tokens

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def test_request_phrase
    visit sign_in_path
    click_on "Sign in"

    refute page.has_content?("ActionController::InvalidAuthenticityToken")

    fill_in "Name", with: "Kagari Mimi"
    fill_in "Email", with: "mimi@example.com"
    click_on "Sign In"

    assert page.has_content?("Hello Kagari Mimi (mimi@example.com)!")
  end
end
