# frozen_string_literal: true

require 'pty'
require 'rspec_flat_error_formatter'

describe RspecFlatErrorFormatter do
  EXAMPLE_DIR = File.expand_path('../example', __dir__)

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
    example_spec_output_lines.to_a.join("\n")
  end

  def example_spec_output_lines
    Enumerator.new do |y|
      execute_example_spec.each_line { |l| y << l.gsub(/\e\[\d+m/, '').chomp }
    end
  end

  describe 'suite' do
    it 'outputs correct progress info for the entire test suite' do
      expect(example_spec_output_lines).to include('.**FFFFFFFFFF')
    end
  end

  describe 'pending examples' do
    it 'has "Pending" block' do
      expect(example_spec_output_lines).to(
        include("Pending: (Failures listed here are expected and do not affect your suite's status)")
      )
    end

    it 'reports a skipped example' do
      expect(example_spec_output_lines).to include('./spec/example_spec.rb:10: info: Skipped (Just skipped)')
    end

    it 'reports a pending example' do
      expect(example_spec_output_lines).to include('./spec/example_spec.rb:14: info: Pending (Just pending)')
    end
  end

  describe 'failures' do
    it 'has "Failures" block' do
      expect(example_spec_output_lines).to include('Failures:')
    end

    it 'reports a failed expectation' do
      expect(example_spec_output_lines).to include('./spec/example_spec.rb:19: error: expected true got false')
    end

    # rubocop:disable RSpec/ExampleLength
    it 'reports a failed expectation having a diff' do
      expect(example_spec_output).to(
        include(<<~OUT)
          ./spec/example_spec.rb:23: error: expected {:a => 1, :b => 2, :c => 3} to include {:d => 1, :e => (have attributes {:f => 2})}
          Diff:
          @@ -1,3 +1,4 @@
          -:d => 1,
          -:e => (have attributes {:f => 2}),
          +:a => 1,
          +:b => 2,
          +:c => 3,
        OUT
      )
    end
    # rubocop:enable RSpec/ExampleLength

    it 'reports an error raised' do
      expect(example_spec_output_lines).to include(
        './spec/example_spec.rb:27: error: ArgumentError: Something went wrong with your arguments'
      )
    end

    it 'reports an error raised along with its cause (having it own message)' do
      expect(example_spec_output_lines).to include(
        "./spec/example_spec.rb:34: error: ArgumentError: ArgumentError, caused by 'RuntimeError: This is the cause' "\
        'at ./spec/example_spec.rb:32'
      )
    end

    it 'reports an error raised along with its cause (without a message)' do
      expect(example_spec_output_lines).to include(
        "./spec/example_spec.rb:42: error: ArgumentError: ArgumentError, caused by 'RuntimeError: RuntimeError' "\
        'at ./spec/example_spec.rb:40'
      )
    end

    it 'reports a fixed but pending example' do
      expect(example_spec_output_lines).to include(
        "./spec/example_spec.rb:67: error: Expected pending 'Pending but actually fixed' to fail. No error was raised."
      )
    end

    describe 'a failure with multiple errors' do
      it 'reports a failed expectation' do
        expect(example_spec_output_lines).to include('./spec/example_spec.rb:59: error: expected false got true')
      end

      it 'reports an error raised in "after" block' do
        expect(example_spec_output_lines).to include('./spec/example_spec.rb:63: error: RuntimeError: Error in "after" block')
      end

      it 'reports an error raised in "around" block and having a cause' do
        expect(example_spec_output_lines).to include(
          './spec/example_spec.rb:54: error: RuntimeError: Error in "around" block (re-raised), caused by '\
          "'RuntimeError: This is the cause' at ./spec/example_spec.rb:52"
        )
      end
    end

    describe 'failures in shared context' do
      it 'reports an error in "before" block' do
        expect(example_spec_output_lines).to include(
          './spec/shared_contexts.rb:5: error: RuntimeError: Error in "before" block'
        )
      end

      it 'reports an error in "let" definition' do
        expect(example_spec_output_lines).to include(
          './spec/shared_contexts.rb:10: error: RuntimeError: Error in "let" definition'
        )
      end

      describe 'a failure with multiple errors' do
        it 'reports a failed expectation' do
          expect(example_spec_output_lines).to include('./spec/example_spec.rb:95: error: expected false got true')
        end

        it 'reports an error raised in "after" block' do
          expect(example_spec_output_lines).to include(
            './spec/shared_contexts.rb:15: error: RuntimeError: Error in "after" block'
          )
        end

        it 'reports an error raised in "around" block' do
          expect(example_spec_output_lines).to include(
            './spec/shared_contexts.rb:22: error: RuntimeError: Error in "around" block'
          )
        end
      end
    end
  end
end
