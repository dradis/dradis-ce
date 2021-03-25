require 'rails_helper'

describe DigestSender do
  describe '#send' do
    before do
      @user = create(:user)
      issue = create(:issue)
      @comment = create(:comment, commentable: issue)
      project = issue.node.project
    end

    context 'instant' do
      before do
        @notification = create(:notification,
          notifiable: @comment,
          action: :create,
          actor: create(:user),
          recipient: @user
        )
      end

      it 'sends a mail with notifications to the user' do
        allow(Notification).to receive(:for_digest).and_return(
          @user.notifications.for_digest(10.minutes.ago)
        )

        args = {
          user: @user,
          notifications: @user.notifications.for_digest(10.minutes.ago),
          type: :instant
        }

        expect(NotificationMailer).to receive(:with).with(args).and_return(
          NotificationMailer.with(args)
        )

        DigestSender.new(type: :instant, user: @user).send
      end
    end

    context 'daily' do
      before do
        @notification = create(:notification,
          notifiable: @comment,
          action: :create,
          actor: create(:user),
          recipient: @user,
          created_at: 1.day.ago + 1.minute
        )
      end

      it 'sends a mail with notifications to the user' do
        allow(Notification).to receive(:for_digest).and_return(
          @user.notifications.for_digest(1.day.ago)
        )

        args = {
          user: @user,
          notifications: @user.notifications.for_digest(1.day.ago),
          type: :daily
        }

        expect(NotificationMailer).to receive(:with).with(args).and_return(
          NotificationMailer.with(args)
        )

        DigestSender.new(type: :daily, user: @user).send
      end
    end
  end
end
