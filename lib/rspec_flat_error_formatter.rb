# frozen_string_literal: true

require 'rspec/core/formatters/console_codes'
require 'rspec/core/formatters/progress_formatter'

class RspecFlatErrorFormatter < RSpec::Core::Formatters::ProgressFormatter
  VERSION = '0.0.1'
  TOKEN_SEPARATOR = ': '

  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump

  def dump_pending(notification)
    return if notification.pending_notifications.empty?

    formatted = +"\nPending: (Failures listed here are expected and do not affect your suite's status)\n\n"

    notification.pending_notifications.each do |pending|
      formatted << "#{pending_example_message(pending.example)}\n"
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

  def pending_example_kind(example)
    example.skipped? ? 'Skipped' : 'Pending'
  end

  def pending_example_message(example)
    formatted_message(
      bt_line: colorizer.wrap(strip_bt_block(backtrace_formatter.backtrace_line(example.location)), :detail),
      severity: colorizer.wrap('info', :pending),
      message: colorizer.wrap("#{pending_example_kind(example)} (#{example.execution_result.pending_message})", :detail)
    )
  end

  def formatted_message(bt_line:, severity:, message:)
    [bt_line, severity, message].join(TOKEN_SEPARATOR)
  end

  def strip_bt_block(bt_line)
    bt_line.split(':in').first
  end

  def colorizer
    ::RSpec::Core::Formatters::ConsoleCodes
  end

  def backtrace_formatter
    RSpec.configuration.backtrace_formatter
  end
end
