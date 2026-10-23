require 'rails_helper'

describe SubscriptionsHelper do
  describe '#subscription_params_for' do
    it 'identifies the subscribable by its type and id' do
      issue = create(:issue)

      expect(helper.subscription_params_for(issue)).to eq({ subscribable_type: 'Issue', subscribable_id: issue.id })
    end
  end
end
