# frozen_string_literal: true

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
end

# TODO: use shared examples
# TODO: add examples using shared contexts
