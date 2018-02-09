# frozen_string_literal: true

require 'rspec/core/formatters/console_codes'
require 'rspec/core/formatters/progress_formatter'

class RspecFlatErrorFormatter < RSpec::Core::Formatters::ProgressFormatter
  VERSION = '0.0.1'

  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump
  def dump_pending(notification)
    return if notification.pending_notifications.length.zero?

    formatted = +"\nPending: (Failures listed here are expected and do not affect your suite's status)\n\n"

    notification.pending_notifications.each do |example_notification|
      formatted << "#{pending_example_message(example_notification.example)}\n"
    end

    output.puts formatted
  end

  def dump_failures(_notification)
    # no-op
  end

  def dump_summary(_notification)
    # TODO: Finished in 0.34138 seconds (files took 0.26296 seconds to load) (copy from BaseFormatter)
    # TODO: 1 example, 0 failures (copy from BaseFormatter)
  end

  protected
  def pending_example_message(example)
    [
      colorizer.wrap(backtrace_formatter.backtrace_line(example.location), :detail),
      colorizer.wrap('info', :pending),
      colorizer.wrap("Pending (#{example.execution_result.pending_message})", :detail)
    ].join(': ')
  end

  def colorizer
    ::RSpec::Core::Formatters::ConsoleCodes
  end

  def backtrace_formatter
    RSpec.configuration.backtrace_formatter
  end
end
