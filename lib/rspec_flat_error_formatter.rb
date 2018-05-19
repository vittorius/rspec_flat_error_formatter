# frozen_string_literal: true

require 'rspec/support'
require 'rspec/core'
require 'rspec/core/formatters/console_codes'
require 'rspec/core/formatters/base_text_formatter'

class RspecFlatErrorFormatter < RSpec::Core::Formatters::BaseTextFormatter
  TOKEN_SEPARATOR = ': '

  RSpec::Core::Formatters.register self, :example_passed, :example_pending, :example_failed, :start_dump

  def start(notification)
    output.puts pluralize(notification.count, 'example')
    output.puts
  end

  def example_passed(_notification)
    output.print colorizer.wrap('.', :success)
  end

  def example_pending(_notification)
    output.print colorizer.wrap('*', :pending)
  end

  def example_failed(_notification)
    output.print colorizer.wrap('F', :failure)
  end

  def start_dump(_notification)
    output.puts
  end

  def dump_pending(notification)
    return if notification.pending_notifications.empty?

    formatted = +"\nPending: (Failures listed here are expected and do not affect your suite's status)\n\n"

    notification.pending_notifications.each do |pending|
      formatted << "#{pending_example_message(pending.example)}\n"
    end

    output.puts formatted
  end

  def dump_failures(notification)
    return if notification.failure_notifications.empty?

    formatted = +"\nFailures:\n\n"

    notification.failure_notifications.each do |failure|
      formatted << "#{failure_message(failure)}\n"
    end

    output.puts formatted
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

  def pending_fixed_failure?(failure)
    failure.example.execution_result.pending_fixed?
  end

  def multiple_exception_error?(failure)
    failure.example.exception.is_a?(RSpec::Core::MultipleExceptionError::InterfaceTag)
  end

  def failure_message(failure)
    if pending_fixed_failure?(failure)
      pending_fixed_message(failure)
    elsif multiple_exception_error?(failure)
      multiple_exceptions_message(failure)
    else
      error_message(failure)
    end
  end

  def pending_fixed_message(failure)
    formatted_message(
      bt_line: colorizer.wrap(format_backtrace_first_line(failure.exception, failure.example), :detail),
      message: colorizer.wrap(
        "Expected pending '#{failure.example.execution_result.pending_message}' to fail. No error was raised.",
        :failure
      ),
      severity: colorizer.wrap('error', :failure)
    )
  end

  # TODO: skip shared example stack frame printing for sub-errors
  def multiple_exceptions_message(failure)
    failure.exception.all_exceptions.map { |ex| error_message_for_example(ex, failure.example) }.join("\n")
  end

  def error_message(failure)
    error_message_for_example(failure.exception, failure.example)
  end

  def error_message_for_example(exception, example)
    formatted_message(
      bt_line: colorizer.wrap(format_backtrace_first_line(exception, example), :detail),
      message: colorizer.wrap(error_failure_message_fragment(exception, example), :failure),
      severity: colorizer.wrap('error', :failure)
    )
  end

  def error_failure_message_fragment(exception, example)
    exception_class = exception_class_name(exception)
    message, diff = *exception.message.split('Diff:')
    [
      exception_class.start_with?('RSpec', 'Rspec') ? '' : "#{exception_class}: ", # only non-RSpec exception classes
      message.tr("\n", ' ').squeeze(' ').strip, # making it a one-liner
      formatted_cause(exception, example),
      diff.nil? ? '' : "\nDiff:" + diff
    ].join
  end

  def formatted_message(bt_line:, severity:, message:)
    [bt_line, severity, message].join(TOKEN_SEPARATOR)
  end

  def exception_class_name(exception)
    name = exception.class.name
    name = '(anonymous error class)' if name == ''
    name
  end

  # violently copy-pasted from RSpec::Core::Formatters::ExceptionPresenter#final_exception
  def last_cause(exception, previous = [])
    cause = exception.cause
    if cause && !previous.include?(cause)
      previous << cause
      last_cause(cause, previous)
    else
      exception
    end
  end

  def formatted_cause(exception, example)
    cause = last_cause(exception)
    if cause == exception
      ''
    else
      ", caused by '#{exception_class_name(cause)}: #{formatted_cause_message(cause)}' "\
      "at #{format_backtrace_first_line(cause, example)}"
    end
  end

  def formatted_cause_message(cause)
    if cause.message.empty?
      class_name = exception_class_name(cause)
      class_name.match?(/anonymous/) ? '<no message>' : class_name
    else
      cause.message
    end
  end

  def format_backtrace_first_line(exception, example)
    strip_bt_block(backtrace_formatter.format_backtrace(exception.backtrace, example.metadata).first)
  end

  def strip_bt_block(bt_line)
    bt_line.split(':in').first
  end

  def pluralize(count, string)
    "#{count} #{string}#{'s' unless count.to_f == 1}"
  end

  def colorizer
    RSpec::Core::Formatters::ConsoleCodes
  end

  def backtrace_formatter
    RSpec.configuration.backtrace_formatter
  end
end
