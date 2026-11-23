require 'rails_helper'

describe ConsoleLogger do
  include ActionCable::TestHelper
  include Turbo::Broadcastable::TestHelper

  let(:logger) { described_class.new(uid: 'job-uid') }
  let(:stream) { described_class.stream_name('job-uid') }

  it 'appends each line to its console, in the order written' do
    broadcasts = capture_turbo_stream_broadcasts(stream) do
      logger.write('Parsing file...')
      logger.info { "\e[32mCreated 12 issues.\e[0m" }
    end

    expect(broadcasts.map { |b| b['action'] }).to eq %w[append append]
    expect(broadcasts.map { |b| b['target'] }.uniq).to eq ['console_job-uid_lines']
    expect(broadcasts.map { |b| b.at_css('p').text }).to eq ['Parsing file...', 'Created 12 issues.']
  end

  it 'logs a failed broadcast instead of raising, so the job carries on' do
    allow(Turbo::StreamsChannel).to receive(:broadcast_append_to).and_raise(Redis::CannotConnectError)
    allow(Rails.logger).to receive(:warn)

    expect { logger.write('Parsing file...') }.not_to raise_error
    expect(Rails.logger).to have_received(:warn).with(/broadcast failed \(Redis::CannotConnectError/)
  end

  it 'replaces the status with the final state' do
    broadcasts = capture_turbo_stream_broadcasts(stream) { logger.complete! }

    expect(broadcasts.first['action']).to eq 'replace'
    expect(broadcasts.first['target']).to eq 'console_job-uid_status'
    expect(broadcasts.first.at_css('[data-state=completed]')).to be_present
  end
end
