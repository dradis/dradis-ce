require 'rails_helper'

describe ActivityTrackingJob do #, type: :job do

  it 'uses correct queue' do
    expect(described_class.new.queue_name).to eq('dradis_project')
  end

  describe '#perform' do
    it 'creates activities' do
      models  = [:issue, :evidence, :note, :node, :comment]
      actions = [:create, :update, :destroy]
      user    = create(:user)

      models.each do |model|
        actions.each do |action|
          trackable = create(model)
          trackable.destroy if action == :destroy

          expect {
            described_class.new.perform(
              action: action.to_s,
              trackable_id: trackable.id,
              trackable_type: trackable.class.to_s,
              user_id: user.id
            )
          }.to change { Activity.count }.by(1)

          activity = Activity.last

          case action.to_s
          when 'create', 'update'
            expect(activity.trackable).to eq trackable
          when 'destroy'
            # 'Destroy' activities should save the type and ID of the destroyed model
            # so we know what they were, even though the specific model doesn't exist
            # anymore.
            expect(activity.trackable).to be_nil
            expect(activity.trackable_type).to eq trackable.class.to_s
            expect(activity.trackable_id).to eq trackable.id
          else
            raise "unrecognized action, must be 'create', 'update' or 'destroy'"
          end

          expect(activity.user).to eq user.email
          expect(activity.action).to eq action.to_s
        end
      end
    end

    it 'creates notifications when a comment is created' do
      commentable = create(:issue)
      create_list(:subscription, 2, subscribable: commentable)
      trackable = create(:comment, commentable: commentable)

      expect {
        described_class.new.perform(
          action: 'create',
          trackable_id: trackable.id,
          trackable_type: trackable.class.to_s,
          user_id: trackable.user.id
        )
      }.to change { Notification.count }.by(2)
    end

    it 'creates notifications when a comment has mentions' do
      issue_owner = create(:user, email: 'owner')
      commentable = create(:issue, author: issue_owner.email)
      create(:subscription, subscribable: commentable)
      mentioned = create(:user, email: 'mentioned')
      trackable = create(
        :comment,
        commentable: commentable,
        content: "Hello @#{mentioned.email} and @#{issue_owner.email}"
      )

      expect {
        described_class.new.perform(
          action: 'create',
          trackable_id: trackable.id,
          trackable_type: trackable.class.to_s,
          user_id: trackable.user_id
        )
      }.to change { Notification.count }.by(3) \
      .and change { Subscription.count }.by(1)

      expect(Notification.where(action: 'mention').count).to eq(2)
      expect(Notification.where(action: 'create').count).to eq(1)
    end
  end
end
