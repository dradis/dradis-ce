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
shared_examples "creates an Activity" do |action, klass=nil|
  it "creates an Activity" do
    expect{submit_form}.to change{Activity.count}.by(1)
    activity = Activity.last

    case action.to_s
    when "create"
      expect(activity.trackable).to eq klass.last
    when "update"
      expect(activity.trackable).to eq model
    when "destroy"
      # 'Destroy' activities should save the type and ID of the destroyed model
      # so we know what they were, even though the specific model doesn't exist
      # anymore.
      expect(activity.trackable).to be_nil
      expect(activity.trackable_type).to eq model.class.to_s
      expect(activity.trackable_id).to eq model.id
    else
      raise "unrecognized action, must be 'create', 'update' or 'destroy'"
    end
    expect(activity.user).to eq @logged_in_as
    expect(activity.action).to eq action.to_s
  end
end


shared_examples "doesn't create an Activity" do
  it "doesn't create an Activity" do
    expect{submit_form}.not_to change{Activity.count}
  end
end


# Define the following let variables before using these examples:
#
#   create_activities : a block which creates the activities AND IS CALLED
#                       BEFORE THE PAGE LOADS
#   trackable: the model which the 'show' page is about
shared_examples "a page with an activity feed" do

  describe "when the model has activities" do
    include ActivityMacros

    let(:create_activities) do
      @activities = [
        create(:update_activity, trackable: trackable),
        create(:create_activity, trackable: trackable)
      ]
      other_instance = create(trackable.class.to_s.underscore)
      @other_activity = create(:activity, trackable: other_instance)
    end

    it "lists them in the activity feed" do
      within activity_feed do
        should have_activity(@activities[0])
        should have_activity(@activities[1])
        should_not have_activity(@other_activity)
      end
    end
  end
end
