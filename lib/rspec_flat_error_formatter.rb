# frozen_string_literal: true

require 'rspec/core/formatters/progress_formatter'

class RspecFlatErrorFormatter < RSpec::Core::Formatters::ProgressFormatter
  VERSION = '0.0.1'

  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump
end
