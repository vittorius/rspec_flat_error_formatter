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
end

# TODO: use shared examples
# TODO: add examples using shared contexts
