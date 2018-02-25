# frozen_string_literal: true

require_relative 'shared_contexts'

describe 'specs with errors' do
  it 'succeeds' do
    expect(true).to be(true)
  end

  it 'is skipped' do
    skip 'Just skipped'
  end

  it 'is pending', pending: 'Just pending' do
    expect(true).to be false
  end

  it 'fails' do
    expect(false).to be(true)
  end

  it 'fails with diff' do
    expect(a: 1, b: 2, c: 3).to include(d: 1, e: have_attributes(f: 2))
  end

  it 'raises an error' do
    raise ArgumentError, 'Something went wrong with your arguments'
  end

  it 'raises an error (with cause)' do
    begin
      raise 'This is the cause'
    rescue RuntimeError
      raise ArgumentError
    end
  end

  it 'raises an error (with cause, but no message)' do
    begin
      raise
    rescue RuntimeError
      raise ArgumentError
    end
  end

  # this test also covers RSpec::Expectations::MultipleExpectationsNotMetError but we don't test for it here explicitly
  # because we don't want this gem to depend on rspec-expectations; there's no real need for it
  describe 'spec with multiple errors' do
    around do |example|
      example.run
      begin
        raise 'This is the cause'
      rescue # rubocop:disable Style/RescueStandardError
        raise 'Error in "around" block (re-raised)'
      end
    end

    it 'fails' do
      expect(true).to be false
    end

    after do
      raise 'Error in "after" block'
    end
  end

  it 'fails because of fixed pending', pending: 'Pending but actually fixed' do
    expect(true).to be true
  end

  context 'with error(s) in shared context' do
    context 'with error in "before" block' do
      include_context 'when in "before" block'

      it 'succeeds' do
        expect(true).to be(true)
      end
    end

    context 'with error in "let" block' do
      include_context 'when in "let" definition'

      before { error }

      it 'succeeds' do
        expect(true).to be(true)
      end
    end

    context 'with multiple errors in an example' do
      include_context 'when in "after" block'
      include_context 'when in "around" block: after the example'

      it 'fails' do
        expect(true).to be(false)
      end
    end
  end
end

# TODO: use shared examples
