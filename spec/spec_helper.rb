# frozen_string_literal: true

require 'bundler/setup'
require 'dotenv'
require 'rspec_flat_error_formatter'

Dotenv.load('.env.test')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  unless ENV['CI'] == 'true'
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end
end
