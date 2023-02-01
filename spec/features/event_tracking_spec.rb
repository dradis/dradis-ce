require 'rails_helper'

describe 'Event Tracking pages:' do
  subject { page }

  before do
    login_to_project_as_user
    @analytics_config = ::Configuration.find_or_initialize_by(name: 'admin:analytics')
  end

  describe 'event_tracking#index' do
    describe 'can toggle event tracking' do
      it 'enables event tracking' do
        @analytics_config.value = 'false'
        @analytics_config.save
        visit project_event_tracking_index_path(current_project)
        expect do
          click_button 'Share statistics with us!'
        end.to change { @analytics_config.reload.value }.from('false').to('true')
        expect(page).to have_text('Event tracking successfully enabled!')
      end
      it 'disables event tracking' do
        @analytics_config.value = 'true'
        @analytics_config.save
        visit project_event_tracking_index_path(current_project)
        expect do
          click_button 'Disable data collection'
        end.to change { @analytics_config.reload.value }.from('true').to('false')
        expect(page).to have_text('Event tracking successfully disabled!')
      end
    end
  end
end
