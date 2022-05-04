# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
ENV["HIDE_THINGS"] = "1"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require File.expand_path("dummy/config/environment.rb", __dir__)

ENV["RAILS_ROOT"] ||= File.dirname(__FILE__) + "dummy"

require "minitest/autorun"

require "factory_bot_rails"
