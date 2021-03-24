require 'rails_helper'

describe NotificationsReaderJob  do #, type: :job do
  it 'uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end

  describe '#perform' do
    context 'project assignment' do
      it 'marks the assignment notification as read' do
        project = create(:project)
        user = create(:user)

        create(:notification, notifiable: project, action: :assign, actor: create(:user), recipient: user)

        expect {
          described_class.new.perform(
            notifiable_type: project.class.to_s,
            notifiable_id: project.id,
            user_id: user.id
          )
        }.to change{ Notification.unread.count }.by(-1)
      end
    end

    context 'issue comments' do
      it 'marks the comment notification as read' do
        commentable = create(:issue)
        comment = create(:comment, commentable: commentable)
        project = commentable.node.project
        user = create(:user)

        create(:notification, notifiable: comment, action: :create, actor: create(:user), recipient: user)

        expect {
          described_class.new.perform(
            notifiable_type: commentable.class.to_s,
            notifiable_id: commentable.id,
            user_id: user.id
          )
        }.to change{ Notification.unread.count }.by(-1)
      end
    end
  end
end
