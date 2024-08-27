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
      let(:project) { current_project }

      let(:create_activities) do
        create_list(:activity, 35,
          user: user,
          trackable_type: trackable.class,
          trackable_id: trackable.id,
          action: 'update',
          project: project,
          created_at: Time.current - 1.month
        )

        create_list(:activity, 10,
          user: second_user,
          trackable_type: trackable_card.class,
          trackable_id: trackable_card.id,
          action: 'update',
          project: project,
          created_at: Time.current
        )

        create_list(:activity, 5,
          user: user,
          trackable_type: trackable_card.class,
          trackable_id: trackable_card.id,
          action: 'update',
          project: project,
          created_at: Time.current - 2.days
        )
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
        context 'valid filter options' do
          it 'has user filter' do
            expect(page).to have_selector('#user_id', count: 1)
          end

          it 'by user' do
            visit project_activities_path(current_project, user_id: second_user.id)
            expect(all('.activity').count).to eq(10)
          end

          it 'has type filter' do
            expect(page).to have_selector('#trackable_type', count: 1)
          end

          it 'by trackable_type' do
            visit project_activities_path(current_project, trackable_type: 'Card')
            expect(page).to have_selector('.activity', count: 15)
          end

          it 'has daterange filter' do
            expect(page).to have_selector('#since', count: 1)
            expect(page).to have_selector('#before', count: 1)
          end

          it 'combined filter works' do
            visit project_activities_path(current_project, trackable_type: 'Card', user_id: second_user.id)
            expect(page).to have_selector('.activity', count: 10)
          end

          it 'filters by date' do
            since = Time.current - 3.days
            before = Time.current

            visit project_activities_path(current_project, since: since, before: before)
            expect(page).to have_selector('.activity', count: 15)
          end

          it 'filters for single day' do
            visit project_activities_path(current_project, since: Time.current, before: Time.current)
            expect(page).to have_selector('.activity', count: 10)
          end
        end

        context 'invalid filter options' do
          context 'invalid dates' do
            it 'returns no activities' do
              since = Time.current + 3.days
              before = Time.current

              visit project_activities_path(current_project, since: since, before: before)
              expect(page).to_not have_selector('.activity')
            end
          end

          context 'invalid trackable type' do
            it 'returns no activities' do
              visit project_activities_path(current_project, trackable_type: 'InvalidType')
              expect(page).to_not have_selector('.activity')
            end
          end

          context 'invalid user' do
            it 'returns no activities' do
              visit project_activities_path(current_project, user_id: -1)
              expect(page).to_not have_selector('.activity')
            end
          end
        end
      end
    end
  end
end
