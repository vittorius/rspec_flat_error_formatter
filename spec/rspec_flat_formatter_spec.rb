# frozen_string_literal: true

require 'pty'
require 'rspec_flat_error_formatter'

describe RspecFlatErrorFormatter do
  EXAMPLE_DIR = File.expand_path('../../example', __FILE__)

  let(:formatter_arguments) { ['--format', 'RspecFlatErrorFormatter'] }
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

  def example_spec_output
    execute_example_spec
  end

  def example_spec_output_lines
    Enumerator.new do |y|
      execute_example_spec.each_line { |l| y << l.gsub(/\e\[\d+m/, '').chomp }
    end
  end

  it 'outputs correct progress info for the entire test suite' do
    expect(example_spec_output_lines.first).to eq '.'
  end
end
