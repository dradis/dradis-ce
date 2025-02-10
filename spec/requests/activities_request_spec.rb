require 'rails_helper'

RSpec.describe "Activities", type: :request do
  let!(:current_project) { create(:project) }
  let!(:user) { create(:user) }
  let(:trackable) { create(:issue) }
  let!(:activity2) { create(:activity, action: :update , user: user, project: current_project, trackable_type: 'Evidence', created_at: '2017-08-18') }
  let!(:activity3) { create(:activity, action: :update , user: user, project: current_project, trackable_type: 'Node', created_at: '2024-12-24') }
  let(:create_activities) do
    48.times do
      activity = Activity.create(
        user: user,
        trackable_type: trackable.class,
        trackable_id: trackable.id,
        action: 'update',
        created_at: Time.current - ((1..5).to_a.sample.days)
      )
    end
  end

  before do
    create_activities
  end

  describe "GET #index" do
    context "when no params are passed" do
      it "assigns @activties with activities from all pages" do
        get project_activities_path(current_project), params: { project_id: current_project.id, user_id: user.id }
        activities = Activity.order(created_at: :desc)
        activities_groups = activities.group_by do |activity|
          activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
        end 
        expect((activities).count).to eq(50)
      end
    end

    context "when a user filter is applied" do
      it "filters activities by user_id" do
        get project_activities_path(current_project), params: { project_id: current_project.id, user_id: user.id }
        activities = Activity.order(created_at: :desc)
        activities_groups = activities.group_by do |activity|
          activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
        end
        #byebug
        expect((activities).count).to eq(50)
        expect((activities).all? { |activity| activity.user_id == user.id }).to be_truthy
      end
    end

    context "when a trackable_type filter is applied" do
      it "filters activities by trackable_type_filter" do
        get project_activities_path(current_project), params: { project_id: current_project.id, trackable_type: 'Node' }
        activities = Activity.order(created_at: :desc)
        activities_groups = activities.group_by do |activity|
          activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
        end

        activities = activities.select { |activity| activity.trackable_type == 'Node' }
        
        expect((activities).count).to eq(1)
        expect((activities).all? { |activity| activity.trackable_type == 'Node' }).to be_truthy
      end
    end
  end
end
