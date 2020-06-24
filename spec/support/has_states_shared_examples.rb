shared_examples 'a model that has states' do |model|
  describe '#state' do
    let(:state) { :draft }
    let(:record) { create(model, state: state) }

    it 'displays the state' do
      expect(record.state).to eq(state)
    end

    it 'updates the state on save' do
      expect do
        record.state = :review
        record.save
      end.to change { record.state }.to(:review)
    end

    it 'does not save invalid states' do
      expect do
        record.state = :invalid_state
        record.save
      end.to change { record.valid? }.to(false)
    end
  end
end
