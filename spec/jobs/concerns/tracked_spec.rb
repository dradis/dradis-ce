require 'rails_helper'

describe Tracked do
  let(:job_class) do
    Class.new(ApplicationJob) do
      include Tracked

      queue_as :tracked_spec

      def self.name
        'TrackedSpecJob'
      end

      def perform(fail_job:)
        tracker.update_state(state: :failed, message: 'Boom') if fail_job
      end
    end
  end

  let(:store) { {} }
  let(:redis_double) { double('redis', expire: true) }
  let(:job_state) { JSON.parse(store.values.last, symbolize_names: true) }

  before do
    allow(redis_double).to receive(:get) { |key| store[key] }
    allow(redis_double).to receive(:set) { |key, value, _options| store[key] = value }
    allow(Resque).to receive(:redis).and_return(redis_double)
  end

  it 'marks the job as completed when it does not fail' do
    job_class.perform_now(fail_job: false)

    expect(job_state[:state]).to eq('completed')
  end

  it 'keeps the failed state and message when the job fails' do
    job_class.perform_now(fail_job: true)

    expect(job_state).to eq({ state: 'failed', message: 'Boom' })
  end
end
