require 'rails_helper'

describe 'Activity pages:' do
  subject { page }

  it 'should require authenticated users' do
    Configuration.create(name: 'admin:password', value: 'rspec_pass')
    visit project_activities_path(create(:project))
    expect(current_path).to eq(login_path)
    expect(page).to have_content('Access denied.')
  end

  context 'as authenticated user' do
    describe 'index page', js: true do
      let(:trackable) { create(:issue) }
      let(:user) { create(:user) }

      let(:create_activities) do
        50.times do
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
    end
  end
end
