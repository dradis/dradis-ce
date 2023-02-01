require 'rails_helper'

describe 'Event Tracking pages:' do
  subject { page }

  before do
    login_to_project_as_user
  end

  describe 'event_tracking#index' do
    describe 'can toggle event tracking' do
      it 'enables event tracking' do
        analytics_config = create(:configuration, name: 'admin:analytics', value: 'false')
        visit project_event_tracking_index_path(current_project)
        expect do
          click_button 'Share statistics with us!'
        end.to change { analytics_config.reload.value }.from('false').to('true')
        expect(page).to have_text('Event tracking successfully enabled!')
      end
      it 'disables event tracking' do
        analytics_config =  create(:configuration, name: 'admin:analytics', value: 'true')
        visit project_event_tracking_index_path(current_project)
        expect do
          click_button 'Disable data collection'
        end.to change { analytics_config.reload.value }.from('true').to('false')
        expect(page).to have_text('Event tracking successfully disabled!')
      end
    end
  end
end
