require 'rails_helper'

describe Log do
  describe '.latest_for' do
    let(:uid) { SecureRandom.uuid }

    it 'returns a new unpersisted log when none exist yet for the uid' do
      log = Log.latest_for(uid)

      expect(log).not_to be_persisted
      expect(log.uid).to eq(uid)
      expect(log.state).to eq(:running)
    end

    it 'returns the most recent log when no terminal line exists yet' do
      Log.create!(uid: uid, text: 'Deleting 1 Issues')
      latest = Log.create!(uid: uid, text: 'Deleted Issue 1...')

      expect(Log.latest_for(uid)).to eq(latest)
    end

    it 'returns the terminal log even if a later, non-terminal line was written after it' do
      Log.create!(uid: uid, text: 'Worker process completed.')
      Log.create!(uid: uid, text: 'Job id is 123.')

      expect(Log.latest_for(uid).state).to eq(:completed)
    end

    it 'prefers a failed terminal line the same way' do
      Log.create!(uid: uid, text: 'Worker process failed.')
      Log.create!(uid: uid, text: 'Job id is 123.')

      expect(Log.latest_for(uid).state).to eq(:failed)
    end
  end

  describe 'broadcasting' do
    it 'targets only the console and status tagged with its own uid' do
      log = Log.new(uid: 'job-uid', text: 'Worker process completed.')

      expect(Turbo::StreamsChannel).to receive(:broadcast_append_to).with(
        'job-uid', hash_including(targets: '[data-behavior~=console][data-console-uid="job-uid"]')
      )
      expect(Turbo::StreamsChannel).to receive(:broadcast_replace_to).with(
        'job-uid', hash_including(targets: '[data-behavior~=status][data-console-uid="job-uid"]')
      )

      log.save!
    end
  end
end
