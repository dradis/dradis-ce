require 'rails_helper'

describe 'Activity pages:' do
  subject { page }

  it 'should require authenticated users' do
    visit project_activities_path(create(:project))
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do
    describe 'index page', js: true do
      let(:trackable) { create(:issue) }
      let(:trackable_card) { create(:card) }
      let(:user) { create(:user) }
      let(:second_user) { create(:user) }
      let(:create_activities) do
        35.times do
          activity = Activity.create(
            user: user,
            trackable_type: trackable.class,
            trackable_id: trackable.id,
            action: 'update',
            project: current_project,
            created_at: Time.current - 1.month
          )
        end

        10.times do
          activity = Activity.create(
            user: second_user,
            trackable_type: trackable_card.class,
            trackable_id: trackable_card.id,
            action: 'update',
            project: current_project,
            created_at: Time.current
          )
        end

        5.times do
          activity = Activity.create(
            user: user,
            trackable_type: trackable_card.class,
            trackable_id: trackable_card.id,
            action: 'update',
            project: current_project,
            created_at: Time.current - 2.days
          )
        end
      end

      before do
        login_to_project_as_user
        create_activities
        visit project_activities_path(current_project)
      end

      it 'shows paginated records' do
        expect(page).to have_selector('.activity', count: Kaminari.config.default_per_page)
      end

      it 'shows unique date headers' do
        activities = Activity.order(created_at: :desc).limit(Kaminari.config.default_per_page)
        activities_groups = activities.group_by do |activity|
          activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
        end

        date_headers = activities_groups.keys

        date_headers.each do |date_header|
          expect(page).to have_content(date_header, count: 1)
        end
      end

      describe 'infinite scroll' do
        before do
          times_to_scroll = (Activity.count / Kaminari.config.default_per_page.to_f).ceil

          times_to_scroll.times do
            page.execute_script('$("[data-behavior=\'view-content\']").scrollTop(100000)')
          end
        end

        it 'loads more records' do
          expect(page).to have_selector('.activity', count: Activity.count)
        end

        it 'shows unique date headers' do
          activities = Activity.order(created_at: :desc)
          activities_groups = activities.group_by do |activity|
            activity.created_at.strftime(Activity::ACTIVITIES_STRFTIME_FORMAT)
          end

          date_headers = activities_groups.keys

          date_headers.each do |date_header|
            expect(page).to have_content(date_header, count: 1)
          end
        end
      end

      describe 'filters' do
        it "has user filter" do
          expect(page).to have_selector('#user', count: 1)
        end

        it "user filter works" do
          visit project_activities_path(current_project, user: second_user.id)
          expect(page).to have_selector('.activity', count: 10)
        end

        it "has type filter" do
          expect(page).to have_selector('#type', count: 1)
        end

        it "type filter works" do
          visit project_activities_path(current_project, type: "Card")
          expect(page).to have_selector('.activity', count: 15)
        end

        it "has daterange filter" do
          expect(page).to have_selector('#period_start', count: 1)
          expect(page).to have_selector('#period_end', count: 1)
        end

        it "daterange filter works" do
          period_start = Time.current - 3.days
          period_end = Time.current

          visit project_activities_path(current_project, period_start: period_start, period_end: period_end)
          expect(page).to have_selector('.activity', count: 15)
        end

        it "daterange filter works for single day" do
          visit project_activities_path(current_project, period_start: Time.current, period_end: Time.current)
          expect(page).to have_selector('.activity', count: 10)
        end

        it "combined filter works" do
          visit project_activities_path(current_project, type: "Card", user: second_user.id)
          expect(page).to have_selector('.activity', count: 10)
        end
      end
    end
  end
end
