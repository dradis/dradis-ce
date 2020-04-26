# For the 'create' action, pass the ActiveRecord class, e.g. Note, as the second
# argument, e.g.:
#
#     include_examples "creates an Activity", :create, Note
#
# For the 'update' and 'destroy' actions, define a let variable called 'model'
# which returns the model that gets updated/destroyed, e.g.:
#
#     let(:model) { @note }
#     include_examples "creates an Activity", :update
#
# (We can't pass @note in directly, as it doesn't exist in the scope where
# include_examples is called.)
#
# For all actions, you also need to have defined a let variable defined called
# 'submit_form' which performs the action that creates/updates/destroys
# the model in question, e.g.:
#
#     let(:submit_form) { click_button "Save" }
#
shared_examples 'creates an Activity' do |action, klass = nil|
  it 'enqueues an ActivityTrackingJob' do
    if action == :create
      expect { submit_form }.to change {
        ActiveJob::Base.queue_adapter.enqueued_jobs.size
      }.by_at_least(1)
      expect(
        ActiveJob::Base.queue_adapter.enqueued_jobs.map { |h| h[:job] }
      ).to include ActivityTrackingJob
      expect(
        ActiveJob::Base.queue_adapter.enqueued_jobs.map { |h1|
          h1[:args].map { |h2| h2['action'] }
        }.flatten
      ).to include 'create'
      expect(
        ActiveJob::Base.queue_adapter.enqueued_jobs.map { |h1|
          h1[:args].map { |h2| h2['trackable_type'] }
        }.flatten
      ).to include klass.to_s
    else
      expect { submit_form }.to have_enqueued_job(ActivityTrackingJob).with(
        action: action.to_s,
        project_id: current_project.id,
        trackable_id: model.id,
        trackable_type: model.class.to_s,
        user_id: @logged_in_as.id
      )
    end
  end
end

shared_examples "doesn't create an Activity" do
  it "doesn't enqueue an ActivityTrackingJob" do
    expect { submit_form }.not_to have_enqueued_job(ActivityTrackingJob)
  end
end

# Define the following let variables before using these examples:
#
#   create_activities : a block which creates the activities AND IS CALLED
#                       BEFORE THE PAGE LOADS
#   trackable: the model which the 'show' page is about
shared_examples 'a page with an activity feed' do

  describe 'when the model has activities' do
    include ActivityMacros

    let(:create_activities) do
      @activities = [
        create(:update_activity, trackable: trackable),
        create(:create_activity, trackable: trackable)
      ]
      other_instance = create(trackable.class.to_s.underscore)
      @other_activity = create(:activity, trackable: other_instance)
    end

    it 'lists them in the activity feed' do
      within activity_feed do
        should have_activity(@activities[0])
        should have_activity(@activities[1])
        should_not have_activity(@other_activity)
      end
    end
  end
end
