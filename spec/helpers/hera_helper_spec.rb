require 'rails_helper'

describe HeraHelper, type: :helper do
  describe '#body_css' do
    it 'includes the controller path, action name, and edition' do
      allow(helper).to receive(:controller_path).and_return('projects/dashboard/issues')
      allow(helper).to receive(:action_name).and_return('index')

      expect(helper.body_css).to eq('projects-dashboard-issues index ce')
    end
  end
end
