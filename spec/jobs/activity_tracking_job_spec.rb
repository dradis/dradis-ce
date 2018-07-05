require 'rails_helper'

describe ActivityTrackingJob do #, type: :job do

  it 'is uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end

  describe '#perform' do
    let(:model) { create(:comment) }

    let(:submit_form) do
      @logged_in_as = model.user

      described_class.new.perform(
        trackable: model,
        action: 'update',
        user: model.user
      )
    end

    include_examples 'creates an Activity', :update, Comment
  end
end
