# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["HIDE_THINGS"] = "1"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require File.expand_path("dummy/config/environment.rb", __dir__)

ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "dummy"

require "minitest/autorun"
require "factory_bot_rails"
require "minitest/rails"
require "capybara/rails"
# require 'rails/test_help'
# require "minitest/rails/capybara"
# require "minitest/rails/action_dispatch"

require 'capybara/rails'
require 'capybara/minitest'

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL
  # Make `assert_*` methods behave like Minitest assertions
  include Capybara::Minitest::Assertions

  # Reset sessions and driver between tests
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
