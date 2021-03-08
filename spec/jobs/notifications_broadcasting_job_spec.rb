require 'rails_helper'

describe NotificationsBroadcastingJob do #, type: :job do
  it 'uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end


  describe '#perform' do
    it 'broadcasts to the notificationschannel' do
      expect(NotificationsChannel).to receive(:broadcast_to).twice

      commentable = create(:issue)
      create_list(:subscription, 2, subscribable: commentable)
      notifiable = create(:comment, commentable: commentable)
      project = commentable.node.project

      described_class.new.perform(
        action: 'create',
        notifiable_id: notifiable.id,
        notifiable_type: notifiable.class.to_s,
        user_id: notifiable.user.id
      )
    end
  end
end
