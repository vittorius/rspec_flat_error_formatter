# frozen_string_literal: true

require 'pty'
require 'rspec_flat_error_formatter'

describe RspecFlatErrorFormatter do
  EXAMPLE_DIR = File.expand_path('../../example', __FILE__)

  # let(:formatter_arguments) { ['--format', 'RspecFlatErrorFormatter'] }
  let(:formatter_arguments) { ['--format', 'documentation'] }
  let(:extra_arguments) { [] }

  let(:color_opt) do
    RSpec.configuration.respond_to?(:color_mode=) ? '--force-color' : '--color'
  end

  # rubocop:disable Metrics/MethodLength, Lint/HandleExceptions
  def safe_pty(command, directory)
    sio = StringIO.new
    begin
      PTY.spawn(*command, chdir: directory) do |r, _, pid|
        begin
          r.each_line { |l| sio.puts(l) }
        rescue Errno::EIO
        ensure
          ::Process.wait pid
        end
      end
    rescue PTY::ChildExited
    end
    sio.string
  end
  # rubocop:enable Metrics/MethodLength, Lint/HandleExceptions

  def execute_example_spec
    command = ['bundle', 'exec', 'rspec', *formatter_arguments, color_opt, *extra_arguments]
    safe_pty(command, EXAMPLE_DIR)
  end

  let(:output) { execute_example_spec }

  subject { puts output }
end
