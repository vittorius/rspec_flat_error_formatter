# frozen_string_literal: true

shared_context 'when in "before" block' do
  before do
    raise 'Error in "before" block'
  end
end

shared_context 'when in "let" definition' do
  let(:error) { raise 'Error in "let" definition' }
end

shared_context 'when in "after" block' do
  after do
    raise 'Error in "after" block'
  end
end

shared_context 'when in "around" block: after the example' do
  around do |example|
    example.run
    raise 'Error in "around" block'
  end
end
