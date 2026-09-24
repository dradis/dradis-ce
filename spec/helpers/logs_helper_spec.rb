require 'rails_helper'

describe LogsHelper do
  let(:completed_log) { Log.new(text: 'Worker process completed.') }
  let(:failed_log) { Log.new(text: 'Worker process failed.') }
  let(:running_log) { Log.new(text: 'Parsing file...') }

  describe '#log_status_class' do
    it 'returns the success class for a completed log' do
      expect(helper.log_status_class(completed_log)).to eq('text-success')
    end

    it 'returns the error class for a failed log' do
      expect(helper.log_status_class(failed_log)).to eq('text-error')
    end

    it 'returns the primary class for a running log' do
      expect(helper.log_status_class(running_log)).to eq('text-primary')
    end

    it 'treats a missing log as running' do
      expect(helper.log_status_class(nil)).to eq('text-primary')
    end
  end

  describe '#log_status_summary' do
    it 'returns the completed summary for a completed log' do
      expect(helper.log_status_summary(completed_log)).to eq('Import complete.')
    end

    it 'returns the failed summary for a failed log' do
      expect(helper.log_status_summary(failed_log)).to eq('Import failed. See the log below for details.')
    end

    it 'returns the running summary for a running log' do
      expect(helper.log_status_summary(running_log)).to eq('Importing…')
    end

    it 'treats a missing log as running' do
      expect(helper.log_status_summary(nil)).to eq('Importing…')
    end
  end
end
