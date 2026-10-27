require "test_helper"
require "rbconfig"

class RequireTest < Minitest::Test
  # `ActionController::Base` is always loaded in this process by the test
  # application, so we check it in a separate process with the same load path.
  def test_require_does_not_load_action_controller_base
    script = <<~RUBY
      require "rails"
      require "action_controller"
      require "omniauth/rails_csrf_protection"

      print $LOADED_FEATURES.any? { |path| path.end_with?("/action_controller/base.rb") }
    RUBY

    output = IO.popen(
      { "RUBYOPT" => nil },
      [RbConfig.ruby, *$LOAD_PATH.map { |path| "-I#{path}" }, "-e", script],
      err: [:child, :out],
      &:read
    )

    assert $?.success?, output
    assert_equal "false", output
  end
end
