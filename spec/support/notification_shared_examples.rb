# Define the following let variables before using these examples:
#   - commentable: a resource that may recive comments, so notifications must created
#
shared_examples 'creates notifications for comments in a' do |klass|
  it "creates notifications for comments in a #{klass}" do
    commentable = create(klass)
    create_list(:subscription, 2, subscribable: commentable)
    trackable = create(:comment, commentable: commentable)
    project = commentable.node.project

    expect {
      described_class.new.perform(
        action: 'create',
        project_id: project.id,
        trackable_id: trackable.id,
        trackable_type: trackable.class.to_s,
        user_id: trackable.user.id
      )
    }.to change { Notification.count }.by(2)
  end
end
