# frozen_string_literal: true

shared_context 'shared context: in "before" block' do
  before do
    raise 'Error in "before" block'
  end
end

shared_context 'shared context: in "let" definition' do
  let(:error) { raise 'Error in "let" definition' }
end

shared_context 'shared context: in "after" block' do
  after do
    raise 'Error in "after" block'
  end
end

shared_context 'shared context: in "around" block: before the example' do
  around do |example|
    raise 'Error in "around" block'
    example.run # rubocop:disable Lint/UnreachableCode
  end
end

shared_context 'shared context: in "around" block: after the example' do
  around do |example|
    example.run
    raise 'Error in "around" block'
  end
end
