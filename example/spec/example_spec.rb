# frozen_string_literal: true

require_relative 'shared_context'
require_relative 'shared_examples'

describe 'specs with example errors' do
  it 'should succeed' do
    expect(true).to be(true)
  end

  it 'should fail' do
    expect(false).to be(true)
  end

  it 'should raise' do
    raise ArgumentError
  end

  it 'should be pending' do
    if defined? skip
      skip
    else
      pending
    end
  end

  it_should_behave_like 'shared examples'
end

describe 'specs with non-example errors' do
  describe 'in "before" block' do
    before do
      raise 'Error in "before" block'
    end

    it 'fails due to error' do
      expect(true).to be(true)
    end
  end

  describe 'in "let" definition' do
    let(:error) { raise 'Error in "let" definition' }

    it 'fails due to error' do
      expect(true).to be(true)
    end
  end

  describe 'in "after" block' do
    after do
      raise 'Error in "after" block'
    end

    it 'fails due to error' do
      expect(true).to be(true)
    end
  end

  describe 'in "around" block: before the example' do
    around do |example|
      raise 'Error in "around" block'
      example.run # rubocop:disable Lint/UnreachableCode
    end

    it 'fails due to error' do
      expect(true).to be(true)
    end
  end

  describe 'in "around" block: after the example' do
    around do |example|
      example.run
      raise 'Error in "around" block'
    end

    it 'fails due to error' do
      expect(true).to be(true)
    end
  end
end

# TODO: use shared examples
# TODO: add examples using shared contexts
