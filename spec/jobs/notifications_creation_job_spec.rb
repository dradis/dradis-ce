require 'rails_helper'

describe NotificationsCreationJob do #, type: :job do

  it 'is uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end

  describe '#perform' do
    it 'creates notifications' do
      issue = create(:issue)
      create_list(:subscription, 2, subscribable: issue)
      actor = create(:user)

      expect {
        described_class.new.perform(
          notifiable: issue,
          action: 'create',
          user: actor
        )
      }.to change { Notification.count }.by(2)
    end
  end
end
