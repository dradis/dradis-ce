require 'rails_helper'

describe JobTracker do
  let(:job_id) { 'test-id' }
  let(:queue_name) { 'test-queue' }

  let(:redis_key) { "#{queue_name}.#{job_id}" }
  let(:tracker) { described_class.new(job_id: job_id, queue_name: queue_name) }

  let(:redis_double) { double('redis') }

  before do
    allow(redis_double).to receive(:get).with(redis_key).and_return(
      { state: 'pending' }.to_json
    )
    allow(redis_double).to receive(:expire)

    allow(Resque).to receive(:redis).and_return(redis_double)
  end

  describe '#state' do
    it 'returns the state of the key' do
      expect(redis_double).to receive(:get).with(redis_key)

      expect(tracker.state).to eq({ state: 'pending' })
    end
  end

  describe '#state=' do
    it 'replaces the hash of the key to with the new  hash' do
      expect(redis_double).to receive(:set).with(redis_key, { state: :failed }.to_json, { keepttl: true })

      tracker.state = { state: :failed }
    end
  end

  describe '#update_state' do
    it 'replaces the hash of the key to with the new  hash' do
      expect(redis_double).to receive(:set).with(redis_key, { state: :completed }.to_json, { keepttl: true })

      tracker.update_state({ state: :completed })
    end
  end

  context 'invalid arguments' do
    describe 'nil job_id' do
      it 'throws an error' do
        expect do
          described_class.new(job_id: nil, queue_name: queue_name)
        end.to raise_error('Missing job identifiers!')
      end
    end

    describe 'nil queue name' do
      it 'throws an error' do
        expect do
          described_class.new(job_id: job_id, queue_name: nil)
        end.to raise_error('Missing job identifiers!')
      end
    end

    describe 'invalid hash keys' do
      it 'skips the redis#set' do
        expect(redis_double).to_not receive(:set)

        tracker.update_state({ fake_key: :test })
      end
    end
  end
end
