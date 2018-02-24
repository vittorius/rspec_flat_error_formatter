# frozen_string_literal: true

shared_examples 'shared examples' do
  describe 'specs with example errors' do
    it 'succeeds in a shared example' do
      expect(true).to be(true)
    end

    it 'fails in a shared example' do
      expect(false).to be(true)
    end

    it 'raises in a shared example' do
      raise ArgumentError
    end

    it 'is pending in a shared example' do
      if defined? skip
        skip 'Skipped in shared example'
      else
        pending 'Pending in shared example'
      end
    end
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
end
