# frozen_string_literal: true

require 'rspec_flat_error_formatter/version'

class RspecFlatErrorFormatter < RSpec::Core::Formatters::ProgressFormatter
  Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump
end
